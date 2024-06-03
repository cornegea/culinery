// panduan_page.dart
import 'package:flutter/material.dart';

class PanduanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Color(0xFFFAF1E4),
      appBar: AppBar(
        title: Text("Panduan Resep Masakan", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ketentuan Umum:",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              _buildListItem("Tulis resep menggunakan akun yang telah terdaftar."),
              _buildListItem("Penulisan resep sesuai ketentuan ejaan bahasa Indonesia."),
              _buildListItem("Resep adalah hasil karya sendiri dan belum pernah diterbitkan di aplikasi serupa atau media lain."),
              SizedBox(height: 16.0),
              Text(
                "Ketentuan Dekripsi:",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              _buildListItem("Dekrispi ini berisi tentang latar belakang menu masakan atau informasi dari menu masakan yang akan di bagi ."),
              SizedBox(height: 16.0),
              Text(
                "Ketentuan Kategori:",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              _buildListItem("Pilihlah kategori sesuai menu masakan yang akan di bagikan, contoh anda membagikan menu masakan ayam bakar pilih lah kategori (daging)."),
              SizedBox(height: 16.0),
              Text(
                "Ketentuan Foto Resep:",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              _buildListItem("Foto wajib memiliki kualitas baik dan tidak terpotong."),
              _buildListItem("Gunakan foto hasil kaya sendiri."),
              _buildListItem("Foto tidak boleh diedit menggunakan frame, watermark, dan collage."),
              SizedBox(height: 16.0),
              Text(
                "Ketentuan Bahan:",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              _buildListItem("Resep menggunakan minimal 3 bahan utama."),
              _buildListItem("Format penulisan bahan: jumlah - satuan - bahan (contoh: 50 gr tahu)."),
              SizedBox(height: 16.0),
              Text(
                "Ketentuan Cara Memasak:",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              _buildListItem("Resep terdiri dari minimal 5 langkah memasak."),
              _buildListItem("Langkah yang dituliskan tidak boleh mengandung produk komersial atau menyebut merek produk."),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, size: 16.0, color: Colors.green),
          SizedBox(width: 8.0),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
