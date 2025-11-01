class CmsModel {
  int? id;
  String? slug;
  String? title;
  String? content;
  int? status;
  String? createdDate;

  CmsModel(
      {this.id,
      this.slug,
      this.title,
      this.content,
      this.status,
      this.createdDate});

  CmsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    title = json['title'];
    content = json['content'];
    status = json['status'];
    createdDate = json['created_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['slug'] = slug;
    data['title'] = title;
    data['content'] = content;
    data['status'] = status;
    data['created_date'] = createdDate;
    return data;
  }
}
