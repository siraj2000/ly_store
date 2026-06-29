import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../widgets/common/app_header.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key, this.orderId});

  final String? orderId;

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatMessage(
        text:
            'Demo support chat${widget.orderId == null ? '' : ' • order #${widget.orderId}'}',
        isCustomer: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppHeader(title: context.tr('Live Chat', 'الدردشة المباشرة')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isCustomer
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: message.isCustomer
                          ? colors.primaryText
                          : colors.surfaceSoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message.localizedText(context),
                      style: TextStyle(
                        color: message.isCustomer
                            ? colors.surface
                            : colors.primaryText,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: context.tr('Type a message', 'اكتب رسالة'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _sendMessage,
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    setState(() {
      _messages.add(_ChatMessage(text: text, isCustomer: true));
      _messages.add(
        const _ChatMessage(
          text:
              'Thanks. This is a demo support chat, so your message is saved only on this screen.',
          arabicText:
              'شكراً. هذه دردشة دعم تجريبية، لذلك رسالتك محفوظة في هذه الشاشة فقط.',
          isCustomer: false,
        ),
      );
      _controller.clear();
    });
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isCustomer,
    this.arabicText,
  });

  final String text;
  final String? arabicText;
  final bool isCustomer;

  String localizedText(BuildContext context) =>
      context.isArabic ? arabicText ?? text : text;
}
