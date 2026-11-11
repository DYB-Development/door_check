class StoredAuthenticator
  def set_up?(user) = user.authenticator_code.present?

  def verify(user, code)
    return :authenticator_app if set_up?(user) && code == user.authenticator_code

    :backup_codes if use_backup_code(user, code)
  end

  def setup_path = "/authenticator/setup"

  private

  def use_backup_code(user, code)
    codes = user.backup_codes.to_s.split(",")
    return false unless codes.delete(code)

    user.update!(backup_codes: codes.join(","))
  end
end
