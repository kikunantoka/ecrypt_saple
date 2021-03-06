class TestsController < ApplicationController
  before_action :set_test, only: [:show, :edit, :update, :destroy]

  SECRET_KEY = "hoge"

  # GET /tests
  # GET /tests.json
  def index
    @tests = Test.all
  end

  # GET /tests/1
  # GET /tests/1.json
  def show
  end

  # GET /tests/new
  def new
    @test = Test.new
  end

  # GET /tests/1/edit
  def edit
  end

  # POST /tests
  # POST /tests.json
  def create
    @origin = test_params[:origin]
    @salt = new_salt
    @encrypted = crypt(@origin,@salt)
    @deceypted = decrypt(@encrypted,@salt)
    @test = Test.new(origin:@origin, encrypted:@encrypted, salt:@salt, deceypted:@deceypted)

    respond_to do |format|
      if @test.save
        format.html { redirect_to @test, notice: 'Test was successfully created.' }
        format.json { render :show, status: :created, location: @test }
      else
        format.html { render :new }
        format.json { render json: @test.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tests/1
  # PATCH/PUT /tests/1.json
  def update
    respond_to do |format|
      if @test.update(test_params)
        format.html { redirect_to @test, notice: 'Test was successfully updated.' }
        format.json { render :show, status: :ok, location: @test }
      else
        format.html { render :edit }
        format.json { render json: @test.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tests/1
  # DELETE /tests/1.json
  def destroy
    @test.destroy
    respond_to do |format|
      format.html { redirect_to tests_url, notice: 'Test was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # 暗号化
  def crypt(password, salt)
    cipher = OpenSSL::Cipher::Cipher.new("AES-256-CBC")
    cipher.encrypt
    cipher.pkcs5_keyivgen(SECRET_KEY, salt)
    cipher.update(password) + cipher.final
  end

  # 復号化
  def decrypt(password, salt)
    cipher = OpenSSL::Cipher::Cipher.new("AES-256-CBC")
    cipher.decrypt
    cipher.pkcs5_keyivgen(SECRET_KEY, salt)
    cipher.update(password) + cipher.final
  end

  # Salt生成
  def new_salt
    source = ("a".."z").to_a + ("A".."Z").to_a + (0..9).to_a + ["_","-","."]
    key=""
    8.times{ key+= source[rand(source.size)].to_s }
    return key
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_test
      @test = Test.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def test_params
      params.require(:test).permit(:origin, :encrypted, :salt, :deceypted)
    end
end
