import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

final cpfFormatter = MaskTextInputFormatter(
  mask: '###.###.###-##',
  filter: {'#': RegExp(r'[0-9]')},
);

final telefoneFormatter = MaskTextInputFormatter(
  mask: '(##) # ####-####',
  filter: {'#': RegExp(r'[0-9]')}
);

final cnpjFormatter = MaskTextInputFormatter(
  mask: 'XX.XXX.XXX/XXXX-##',
  filter: { 'X': RegExp(r'[0-9A-Za-z]'), '#': RegExp(r'[0-9]'),
  },
);