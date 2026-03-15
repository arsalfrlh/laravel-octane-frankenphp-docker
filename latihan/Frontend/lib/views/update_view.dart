import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toko/viewmodels/barang_viewmodel.dart';

class UpdateView extends StatefulWidget {
  final int barangId;
  const UpdateView({required this.barangId});

  @override
  State<UpdateView> createState() => _UpdateViewState();
}

class _UpdateViewState extends State<UpdateView> {
  final nmBarang = TextEditingController();
  final merkController = TextEditingController();
  final stokController = TextEditingController();
  final hargaController = TextEditingController();
  List<XFile> gambar = [];
  List<Map<String, dynamic>> gambarOld = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final vm = Provider.of<BarangViewmodel>(context, listen: false);
      await vm.showBarang(widget.barangId);
      nmBarang.text = vm.currentBarang?.namaBarang ?? "";
      merkController.text = vm.currentBarang?.merk ?? "";
      stokController.text = vm.currentBarang?.stok.toString() ?? "";
      hargaController.text = vm.currentBarang?.harga.toString() ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<BarangViewmodel>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFF00BF6D),
        foregroundColor: Colors.white,
        title: const Text("Update Barang"),
      ),
      body: vm.isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  ListView.builder(
                    itemCount: vm.currentBarang?.gambarList.length ?? 0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ProfilePic(
                        image: vm.currentBarang?.gambarList[index].namaGambar,
                        imageUploadBtnPress: () async {
                          final pickedFile = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            if (gambar.length ==
                                vm.currentBarang?.gambarList.length) {
                              setState(() {
                                gambar[index] = pickedFile;
                                gambarOld[index] = {
                                  "id": vm.currentBarang?.gambarList[index].id,
                                  "nama_gambar": vm.currentBarang
                                      ?.gambarList[index].namaGambar
                                };
                              });
                            } else {
                              setState(() {
                                gambar.add(pickedFile);
                                gambarOld.add({
                                  "id": vm.currentBarang?.gambarList[index].id,
                                  "nama_gambar": vm.currentBarang
                                      ?.gambarList[index].namaGambar
                                });
                              });
                            }
                          }
                        },
                      );
                    },
                  ),
                  const Divider(),
                  Form(
                    child: Column(
                      children: [
                        UserInfoEditField(
                          text: "Nama Barang",
                          child: TextFormField(
                            controller: nmBarang,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color(0xFF00BF6D).withOpacity(0.05),
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
                        UserInfoEditField(
                          text: "Merk",
                          child: TextFormField(
                            controller: merkController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color(0xFF00BF6D).withOpacity(0.05),
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
                        UserInfoEditField(
                          text: "Stok",
                          child: TextFormField(
                            controller: stokController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color(0xFF00BF6D).withOpacity(0.05),
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
                        UserInfoEditField(
                          text: "Harga",
                          child: TextFormField(
                            controller: hargaController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color(0xFF00BF6D).withOpacity(0.05),
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
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .color!
                                .withOpacity(0.08),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      SizedBox(
                        width: 160,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BF6D),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: vm.isLoading
                              ? null
                              : () async {
                                  final response = await vm.updateBarang(
                                      vm.currentBarang!.id,
                                      nmBarang.text,
                                      merkController.text,
                                      int.parse(stokController.text),
                                      int.parse(hargaController.text),
                                      gambar,
                                      gambarOld);
                                  AwesomeDialog(
                                          context: context,
                                          dialogType: response
                                              ? DialogType.success
                                              : DialogType.error,
                                          animType: AnimType.bottomSlide,
                                          dismissOnTouchOutside: false,
                                          title: response ? "Sukses" : "Error",
                                          desc: vm.message,
                                          btnOkOnPress: () {
                                            if (response) {
                                              Navigator.pop(context);
                                            }
                                          },
                                          btnOkColor: response
                                              ? Colors.green
                                              : Colors.red)
                                      .show();
                                },
                          child: const Text("Save Update"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class ProfilePic extends StatelessWidget {
  const ProfilePic({
    super.key,
    this.image,
    this.imageUploadBtnPress,
  });

  final String? image;
  final VoidCallback? imageUploadBtnPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color:
              Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.08),
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 50,
            child: CachedNetworkImage(
              imageUrl: "http://10.0.2.2:8081/storage/images/$image",
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Icon(
                Icons.broken_image,
                size: 80,
              ),
            ),
          ),
          InkWell(
            onTap: imageUploadBtnPress,
            child: CircleAvatar(
              radius: 13,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class UserInfoEditField extends StatelessWidget {
  const UserInfoEditField({
    super.key,
    required this.text,
    required this.child,
  });

  final String text;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0 / 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(text),
          ),
          Expanded(
            flex: 3,
            child: child,
          ),
        ],
      ),
    );
  }
}
