import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toko/models/message.dart';
import 'package:toko/models/user.dart';
import 'package:toko/viewmodels/message_viewmodel.dart';

class MessageView extends StatefulWidget {
  const MessageView({required this.sender, required this.receiver});
  final User sender, receiver;

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  final messageController = TextEditingController();
  XFile? gambar;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final vm = Provider.of<MessageViewmodel>(context, listen: false);
      vm.fetchMessage(widget.receiver.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MessageViewmodel>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFF00BF6D),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            BackButton(),
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Icon(
                Icons.person,
                size: 40,
              ),
            ),
            SizedBox(width: 16.0 * 0.75),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiver.name,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  widget.receiver.email,
                  style: TextStyle(fontSize: 12),
                )
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_phone),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {},
          ),
          const SizedBox(width: 16.0 / 2),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                itemCount: vm.messageList.length,
                itemBuilder: (context, index) => Messages(
                  message: vm.messageList[index],
                  sender: widget.sender,
                  onPressed: () {
                    AwesomeDialog(
                            context: context,
                            dialogType: DialogType.warning,
                            animType: AnimType.bottomSlide,
                            title: "Detail",
                            desc: vm.messageList[index].message,
                            btnOkOnPress: () {
                              setState(() {
                                messageController.text =
                                    vm.messageList[index].message;
                              });
                              vm.onUpdate(vm.messageList[index].id);
                            },
                            btnOkText: "Update",
                            btnCancelOnPress: () async {
                              vm.deleteMessage(vm.messageList[index].id);
                            },
                            btnCancelText: "Delete")
                        .show();
                  },
                ),
              ),
            ),
          ),
          ChatInputField(
            message: messageController,
            receiver: widget.receiver,
            onSubmit: () {
              setState(() {
                messageController.clear();
                gambar = null;
              });
            },
          ),
        ],
      ),
    );
  }
}

class ChatInputField extends StatefulWidget {
  ChatInputField(
      {required this.message,
      this.gambar,
      required this.onSubmit,
      required this.receiver});
  final TextEditingController message;
  XFile? gambar;
  final VoidCallback onSubmit;
  final User receiver;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _showAttachment = false;

  void _updateAttachmentState() {
    setState(() {
      _showAttachment = !_showAttachment;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MessageViewmodel>(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0 / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -4),
            blurRadius: 32,
            color: const Color(0xFF087949).withOpacity(0.08),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: vm.isUpdate
                        ? () {
                            vm.onCancelUpdate();
                            widget.onSubmit();
                          }
                        : null,
                    icon: Icon(Icons.close, color: Color(0xFF00BF6D))),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(width: 16.0 / 4),
                      Expanded(
                        child: TextField(
                          controller: widget.message,
                          decoration: InputDecoration(
                            hintText: "Type message",
                            suffixIcon: SizedBox(
                              width: 65,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: _updateAttachmentState,
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      color: _showAttachment
                                          ? const Color(0xFF00BF6D)
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .color!
                                              .withOpacity(0.64),
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0 / 2),
                                      child: InkWell(
                                        onTap: vm.isLoading
                                            ? null
                                            : () async {
                                                if (widget
                                                    .message.text.isNotEmpty) {
                                                  vm.isUpdate
                                                      ? await vm.updateMessage(
                                                          widget.message.text,
                                                          widget.gambar)
                                                      : await vm.sendMessage(
                                                          widget.receiver.id,
                                                          widget.message.text,
                                                          widget.gambar);
                                                  widget.onSubmit();
                                                }
                                              },
                                        child: vm.isLoading
                                            ? CircularProgressIndicator()
                                            : Icon(
                                                Icons.send,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color!
                                                    .withOpacity(0.64),
                                              ),
                                      )),
                                ],
                              ),
                            ),
                            filled: true,
                            fillColor:
                                const Color(0xFF00BF6D).withOpacity(0.08),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0 * 1.5, vertical: 16.0),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_showAttachment) const MessageAttachment(),
          ],
        ),
      ),
    );
  }
}

class MessageAttachment extends StatelessWidget {
  const MessageAttachment({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      // color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MessageAttachmentCard(
            iconData: Icons.insert_drive_file,
            title: "Document",
            press: () {},
          ),
          MessageAttachmentCard(
            iconData: Icons.image,
            title: "Gallary",
            press: () {},
          ),
          MessageAttachmentCard(
            iconData: Icons.headset,
            title: "Audio",
            press: () {},
          ),
          MessageAttachmentCard(
            iconData: Icons.videocam,
            title: "Video",
            press: () {},
          ),
        ],
      ),
    );
  }
}

class MessageAttachmentCard extends StatelessWidget {
  final VoidCallback press;
  final IconData iconData;
  final String title;

  const MessageAttachmentCard(
      {super.key,
      required this.press,
      required this.iconData,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Padding(
        padding: const EdgeInsets.all(16.0 / 2),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0 * 0.75),
              decoration: const BoxDecoration(
                color: Color(0xFF00BF6D),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                size: 20,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            const SizedBox(height: 16.0 / 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withOpacity(0.8),
                  ),
            )
          ],
        ),
      ),
    );
  }
}

class Messages extends StatelessWidget {
  const Messages(
      {super.key,
      required this.message,
      required this.sender,
      required this.onPressed});

  final Message message;
  final User sender;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: message.user.id == sender.id
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (message.gambar != null) ...[
            VideoMessage(message: message),
            SizedBox(
              width: 10,
            ),
          ],
          TextMessage(
            message: message,
            sender: sender,
            onPressed: onPressed,
          )
        ],
      ),
    );
  }
}

class VideoMessage extends StatelessWidget {
  const VideoMessage({required this.message});
  final Message message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45, // 45% of total width
      child: AspectRatio(
        aspectRatio: 1.6,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                "http://10.0.2.2:8081/storage/${message.gambar}",
                fit: BoxFit.cover,
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.broken_image,
                  size: 80,
                ),
              ),
            ),
            Container(
              height: 25,
              width: 25,
              decoration: const BoxDecoration(
                color: Color(0xFF00BF6D),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 16,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TextMessage extends StatelessWidget {
  const TextMessage(
      {super.key,
      required this.message,
      required this.sender,
      required this.onPressed});

  final Message message;
  final User sender;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0 * 0.75,
          vertical: 16.0 / 2,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF00BF6D)
              .withOpacity(message.user.id == sender.id ? 1 : 0.1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          message.message,
          style: TextStyle(
            color: message.user.id == sender.id
                ? Colors.white
                : Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
      ),
    );
  }
}
