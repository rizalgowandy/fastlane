describe Match do
  describe Match::Encryption::OpenSSL do
    before do
      @directory = Dir.mktmpdir
      profile_path = "./match/spec/fixtures/test.mobileprovision"
      FileUtils.cp(profile_path, @directory)
      @full_path = File.join(@directory, "test.mobileprovision")
      @content = File.binread(@full_path)
      @git_url = "https://github.com/fastlane/fastlane/tree/master/so_random"
      allow(Dir).to receive(:mktmpdir).and_return(@directory)

      @e = Match::Encryption::OpenSSL.new(
        keychain_name: @git_url,
        working_directory: @directory
      )
    end

    around do |example|
      FastlaneSpec::Env.with_env_values(MATCH_PASSWORD: '2"QAHg@v(Qp{=*n^') { example.run }
    end

    it "first encrypt, different content, then decrypt, initial content again" do
      @e.encrypt_files
      expect(File.binread(@full_path)).to_not(eq(@content))

      @e.decrypt_files
      expect(File.binread(@full_path)).to eq(@content)
    end

    it "raises an exception if invalid password is passed" do
      @e.encrypt_files
      expect(File.read(@full_path)).to_not(eq(@content))

      FastlaneSpec::Env.with_env_values(MATCH_PASSWORD: 'invalid') do
        expect do
          @e.decrypt_files
        end.to raise_error("Invalid password passed via 'MATCH_PASSWORD'")
      end
    end

    it "raises an exception if no password is supplied" do
      FastlaneSpec::Env.with_env_values(MATCH_PASSWORD: '') do
        expect do
          @e.encrypt_files
        end.to raise_error("No password supplied")
      end
    end
  end
end
