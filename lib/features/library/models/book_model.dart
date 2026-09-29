// Mirrors the `books/{bookId}` Firestore document.
import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String id;
  final String title;
  final String author;
  final String category;
  final int availableQuantity;
  final String? description;
  final String? imageUrl;
  final String? coverBase64; // fallback cover stored on the doc if Storage upload fails
  final String? isbn;
  final int? publicationYear;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.availableQuantity,
    this.description,
    this.imageUrl,
    this.coverBase64,
    this.isbn,
    this.publicationYear,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory BookModel.fromMap(String id, Map<String, dynamic> data) {
    return BookModel(
      id: id,
      title: data['title'] as String? ?? '',
      author: data['author'] as String? ?? '',
      category: data['category'] as String? ?? 'Uncategorized',
      availableQuantity: (data['availableQuantity'] as num?)?.toInt() ?? 0,
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,
      coverBase64: data['coverBase64'] as String?,
      isbn: data['isbn'] as String?,
      publicationYear: (data['publicationYear'] as num?)?.toInt(),
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'category': category,
      'availableQuantity': availableQuantity,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (coverBase64 != null) 'coverBase64': coverBase64,
      if (isbn != null) 'isbn': isbn,
      if (publicationYear != null) 'publicationYear': publicationYear,
      'createdBy': createdBy,
    };
  }
}
