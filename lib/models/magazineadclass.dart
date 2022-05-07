class Magazine {
  String type;
  String key;
  String url;
  String mediaUrls_Ar;
  String mediaUrls_En;
  int priority;
  String sponsor;

  Magazine({
    this.type,
    this.key,
    this.url,
    this.mediaUrls_En,
    this.mediaUrls_Ar,
    this.priority,
    this.sponsor,
  });

  factory Magazine.fromJson(Map<String, dynamic> json){
    return Magazine(
        type: 'magazine',
        priority: json['p'],
        url: json['u'],
        mediaUrls_En: json['e'],
        mediaUrls_Ar: json['a'],
        sponsor: json['s'],
    );
  }
  /*Magazine.fromSnapshot(DataSnapshot snapshot)
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
        "p": priority,
        "u": url,
        "e": mediaUrls_En,
        "a": mediaUrls_Ar,
        "s": sponsor
      }
    };
  }

}
