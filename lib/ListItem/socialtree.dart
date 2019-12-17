class SocialTree {
  String id,
      user_id,
      name,
      gender,
      relationship,
      occupation,
      address,
      number,
      email,
      profile_image_url,
      entry_mode;
  dynamic created_date;

  SocialTree(this.id, this.user_id, this.name, this.gender, this.relationship,
      this.occupation, this.address, this.number, this.email,
      this.profile_image_url, this.entry_mode, this.created_date);

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'user_id': user_id,
      'name': name,
      'gender': gender,
      'relationship': relationship,
      'occupation': occupation,
      'address': address,
      'number': number,
      'email': email,
      'profile_image_url': profile_image_url,
      'entry_mode': entry_mode,
      'created_date': created_date
    };
  }

}

class SocialEvents {
  String event_name, event_date;
  int event_timestamp;
  int event_day, event_month, event_year;
  String social_tree_id, user_id;

  SocialEvents(this.event_name, this.event_date, this.event_timestamp,
      this.event_day, this.event_month, this.event_year, this.social_tree_id,
      this.user_id);

  Map<String, dynamic> toJSON() {
    return {
      'event_name':event_name,
      'event_date':event_date,
      'event_timestamp':event_timestamp,
      'event_day':event_day,
      'event_month':event_month,
      'event_year':event_year,
      'social_tree_id':social_tree_id,
      'user_id':user_id
    };
  }
}
