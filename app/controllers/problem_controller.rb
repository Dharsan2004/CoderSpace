require 'rest-client'


class ProblemController < ApplicationController
  before_action :require_admin, only: [:new, :create, :edit, :update,:destroy]
  before_action :require_user , only: [:show,:index,:submit,:filter,:submit]


  def index
    @coding_problems2 = CodingProblem.all
    @topics = @coding_problems2.pluck(:topic).uniq

    if params[:query].present?
      @coding_problems = Kaminari.paginate_array(CodingProblem.search(params[:query])).page(params[:page]).per(6)
    else
      @coding_problems = CodingProblem.page(params[:page]).per(6)
    end
  end


  def filter
    difficulty = params[:difficulty]
    topic = params[:topic]
    @coding_problems = CodingProblem.all
    @topics = @coding_problems.pluck(:topic).uniq

    @coding_problems = @coding_problems.where(difficulty: difficulty) if difficulty.present?
    @coding_problems = @coding_problems.where(topic: topic) if topic.present?

    @coding_problems = @coding_problems.page(params[:page]).per(6) # Adjust per page value as needed

    render :index, status: :unprocessable_entity
  end

  def new
    @coding_problem = CodingProblem.new
  end

  def create

    @coding_problem = CodingProblem.new(coding_problem_params)

    if @coding_problem.save
      redirect_to problem_path(@coding_problem), notice: 'Coding problem was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @coding_problem = CodingProblem.find_by(id: params[:id])

    if @coding_problem.nil?
      flash[:alert] = "Coding problem not found."
      if admin?
        redirect_to "/admin_page"
      else
        redirect_to "/page"
      end
    end
  end

  def edit
    @coding_problem = CodingProblem.find_by(id: params[:id])

    if @coding_problem.nil?
      flash[:alert] = "Coding problem not found."
      if admin?
        redirect_to "/admin_page"
      else
        redirect_to "/page"
      end
    end
  end

  def update
    @coding_problem = CodingProblem.find_by(id: params[:id])

    if @coding_problem.nil?
      flash[:alert] = "Coding problem not found."
      if admin?
        redirect_to "/admin_page"
      else
        redirect_to "/page"
      end
      return
    end

    if @coding_problem.update(coding_problem_params)
      flash[:notice] = "Coding problem edited successfully"
      redirect_to problem_path(@coding_problem)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy

    @coding_problem = CodingProblem.find_by(id: params[:id])

    if @coding_problem.nil?
      flash[:alert] = "Coding problem not found."
      if admin?
        redirect_to "/admin_page"
      else
        redirect_to "/page"
      end
      return
    end
    begin
      @coding_problem.destroy
      flash[:notice] = "Coding problem deleted successfully"
      redirect_to problem_index_path
    rescue Faraday::ConnectionFailed => e
      Rails.logger.error "Elasticsearch connection failed: #{e.message}"
      flash[:alert] = "Failed to connect to search service. Please try again later."
    ensure
      redirect_to problem_index_path
    end
  end

  # running the code file got from user
  def submit
    #debugger
    p params

    coding_problem = CodingProblem.find(params[:coding_problem_id])
    code_file = params[:code_file]

    if code_file.present? && coding_problem.input_file.present?
      p "hello buddy"
      send_to_express_api(coding_problem, code_file)
    else
      flash[:error] = "Both input file and code file are required"
      redirect_to problem_path(coding_problem)
    end
  end

  private

  def coding_problem_params
    params.require(:coding_problem).permit(:problem_name, :problem_statement, :sample_input, :sample_output, :difficulty, :topic, :input_file, :expected_output_file)
  end

  def send_to_express_api(coding_problem, code_file)
    input_file = download_blob_to_tempfile(coding_problem.input_file)
    code_file_temp = create_tempfile_from_uploaded_file(code_file)

    file_extension = File.extname(code_file.original_filename)
    endpoint = case file_extension
               when '.py'
                 'http://localhost:8000/execute_py'
               when '.cpp'
                 'http://localhost:8000/execute_cpp'
               else
                 Rails.logger.error("Unsupported file extension: #{file_extension}")
                 flash[:error] = "Unsupported file extension"
                 redirect_to problem_path(coding_problem)
                 return
               end

    begin
      response = RestClient.post(endpoint,
                                 { code: code_file_temp, input: input_file },
                                 { content_type: :multipart })
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error("Error from Express API: #{e.response}")
      flash[:error] = e.response
      redirect_to problem_path(coding_problem)
      return
    rescue Errno::ECONNREFUSED => e
      Rails.logger.error("Connection refused: #{e.message}")
      flash[:error] = "Unable to connect to the code execution service. Please try again later."
      redirect_to problem_path(coding_problem)
      return
    end

    Rails.logger.info("Response from Express API: #{response.body}")
    user_output = response.body.strip

    # Read the expected output and convert it to a string while preserving newlines
    expected_output = download_blob_to_tempfile(coding_problem.expected_output_file).read

    # Compare user output with expected output
    if normalize_newlines(user_output) == normalize_newlines(expected_output)
      flash[:notice] = "Accepted"
      p user_output
      # Check if the user has already solved this problem and currentUser is not admin
      unless current_user.solved_problems.exists?(coding_problem_id: coding_problem.id) || admin?
        current_user.solved_problems.create(coding_problem: coding_problem)
      end
    else
      p user_output
      flash[:alert] = "Wrong answer. Your output is:\n#{user_output}"
    end

    redirect_to problem_path(coding_problem)
  ensure
    code_file_temp.close
    code_file_temp.unlink # Deletes the temp file
    input_file.close
    input_file.unlink # Deletes the temp file
  end


  # Helper method to normalize newlines in a string
  def normalize_newlines(str)
      str.gsub(/\r\n/, "\n").strip
  end

  def download_blob_to_tempfile(blob)
    tempfile = Tempfile.new
    tempfile.binmode
    tempfile.write(blob.download)
    tempfile.rewind
    tempfile
  end

  def create_tempfile_from_uploaded_file(uploaded_file)
    tempfile = Tempfile.new
    tempfile.binmode
    tempfile.write(uploaded_file.read)
    tempfile.rewind
    tempfile
  end


end
