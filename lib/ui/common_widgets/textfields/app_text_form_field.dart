import 'package:flutter/material.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';

class AppTextFormField extends StatefulWidget {
  const AppTextFormField({
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.validator,
    this.obscureText = false,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool obscureText;

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  late final _focusNode = widget.focusNode ?? FocusNode();

  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _errorText != null) {
        setState(() => _errorText = null);
      }
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  String? _validator(String? value) {
    final error = widget.validator?.call(value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _errorText = error);
    });
    return error;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(widget.labelText!, style: context.textTheme.titleSmall),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          validator: _validator,
          obscureText: widget.obscureText,
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: '',
            errorStyle: const TextStyle(fontSize: 0),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorText!,
            style: context.textTheme.bodySmall?.copyWith(
              color: Colors.red,
              letterSpacing: 0,
            ),
          ),
        ],
      ],
    );
  }
}
