import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final String? suffix;
  final bool isPassword;
  final TextEditingController? controller;
  final ValueChanged<String?>? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffix,
    this.isPassword = false,
    this.controller,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          obscureText: _obscure,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  )
                : (widget.suffix != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Center(child: Text(widget.suffix!)),
                        )
                      : null),
          ),
        ),
      ],
    );
  }
}
