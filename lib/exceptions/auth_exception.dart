class AuthException implements Exception {
  static const Map<String, String> errors = {
    'EMAIL_EXISTS': 'Este e-mail já está em uso.',
    'OPERATION_NOT_ALLOWED': 'Operação não permitira!;',
    'TOO_MANY_ATTEMPTS_TRY_LATER': 'Acesso bloqueqado temporariamente. Tente mais tarde.',
    'EMAIL_NOT_FOUND': 'E-mail não encontrado.',
    'INVALID_PASSWORD': 'Senha inválida',
    'USER_DISABLED': 'A Conta do usuário foi desabilitada',
    'INVALID_LOGIN_CREDENTIALS': "Credenciais inválidas",
  };

  final String key;
  AuthException(this.key);

  @override
  String toString() {
    return errors[key] ?? 'Ocorreu um erro no processo de autenticação.';
  }
}
