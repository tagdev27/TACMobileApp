class Tracking {
  String title,text,icon,time;

  Tracking(this.title,this.text,this.icon,this.time);

  Map<String, dynamic> toJSON() {
    return new Map.from({
      'title': title,
      'text': text,
      'icon': icon,
      'time': time
    });
  }
}