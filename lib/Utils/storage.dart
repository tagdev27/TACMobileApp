//import 'package:localstorage/localstorage.dart';
import 'package:prefs/prefs.dart';

class StorageSystem {

  StorageSystem() {
    Prefs.init();
  }

  //final LocalStorage storage = new LocalStorage('tac_online_gift_shop');

  void setPrefItem(String key, String item) {
//    storage.ready.then((val){
//      if(val){
//
//      }
//    });
    Prefs.setString(key, item);
  }

  Future<String> getPrefItem(String key) async {
    //return storage.getItem(key);
    String res = await Prefs.getStringF(key, "");
    return res;
  }

  String getItem(String key) {
    return Prefs.getString(key, "");
  }

  void clearPref(){
    //storage.clear();
    Prefs.clear();
  }

  void deletePref(String key){
    //storage.deleteItem(key);
    Prefs.remove(key);
  }

  void disposePref(){
    Prefs.dispose();
  }
}