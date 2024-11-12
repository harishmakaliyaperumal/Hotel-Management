class Language{
  final int id;
  // final String flag;
  final String name;
  final String languageCode;

 Language(this.id,this.name,this.languageCode);

 static List<Language>languageList(){
   return <Language>[
     Language(1,"English", "en"),
     Language(2,"Norwegian", "no"),
   ];
 }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Language &&
              runtimeType == other.runtimeType &&
              languageCode == other.languageCode;

  @override
  int get hashCode => languageCode.hashCode;
}


