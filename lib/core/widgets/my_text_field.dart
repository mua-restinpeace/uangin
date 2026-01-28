import 'package:flutter/material.dart';
import 'package:uangin/core/theme/colors.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final bool isObscureText;
  final Widget? prefixIcon;
  final Widget? sufixIcon;
  final String? errorMsg;
  final TextInputType? textInputType;
  final String? Function(String?)? validator;
  final void Function(String?)? onChange;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  const MyTextField(
      {super.key,
      required this.textEditingController,
      required this.hintText,
      this.isObscureText = false,
      this.prefixIcon,
      this.sufixIcon,
      this.errorMsg,
      this.textInputType = TextInputType.text,
      this.validator,
      this.onChange,
      this.onTap,
      this.focusNode});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: textEditingController,
        validator: validator,
        obscureText: isObscureText,
        keyboardType: textInputType,
        onChanged: onChange,
        focusNode: focusNode,
        onTap: onTap,
        cursorColor: MyColors.onPrimary,
        decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: prefixIcon,
                  )
                : null,
            suffixIcon: sufixIcon,
            hintText: hintText,
            hintStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: MyColors.grey),
            filled: true,
            fillColor: MyColors.fillColor,
            // contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: _border(MyColors.lightGrey),
            enabledBorder: _border(MyColors.lightGrey),
            focusedBorder: _border(MyColors.grey)));
            
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color));
  }
}
