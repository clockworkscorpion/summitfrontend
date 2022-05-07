class Featured {
  String type;
  String key;
  String url;
  String mediaUrls_Ar;
  String mediaUrls_En;
  String bgmedia;

  Featured({
    this.type,
    this.key,
    this.url,
    this.mediaUrls_Ar,
    this.mediaUrls_En,
    this.bgmedia,
  });

  factory Featured.fromJson(Map<String, dynamic> json){
    return Featured(
        type: 'featured',
        url: json['u'],
        mediaUrls_Ar: json['a'],
        mediaUrls_En: json['e'],
        bgmedia: json['b'],
    );
  }
  /*Featured.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        priority = snapshot.value["t"],
        title_en = snapshot.value["te"],
        title_ar = snapshot.value["ta"],
        text_en = snapshot.value["ae"],
        text_ar = snapshot.value["aa"],
        url = snapshot.value["u"],
        mediaUrl = snapshot.value["i"],
        source_en = snapshot.value["se"],
        source_ar = snapshot.value["sa"],
        adtype = snapshot.value["c"];*/

  toJson() {
    return {
      key:
      {
        "u": url,
        "e": mediaUrls_En,
        "a": mediaUrls_Ar,
        "b": bgmedia,
      }
    };
  }

}
