class UpdateLetsEncryptJob < Resque::Job
  @queue = :high

  def self.perform
    existing_cert = OpenSSL::X509::Certificate.new File.read("#{Rails.root}/certificates/app.eve-razor.com-cert.pem")
    return if existing_cert.not_after > DateTime.now + 48.hours
    yml_config = YAML.load_file("#{Rails.root}/config/letsencrypt_plugin.yml") || {}
    cert_generator = LetsencryptPlugin::CertGenerator.new(private_key: "keys/keyfile.pem", output_cert_dir: "certificates", challenge_dir_name: "challenge", domain: "app.eve-razor.com", endpoint: "https://acme-v01.api.letsencrypt.org/", email: "rg-littlephish@eve-razor.com")
    cert_generator.generate_certificate
  end
end