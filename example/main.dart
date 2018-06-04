

import 'dart:async';
import "dart:html";
import "package:CreditsLib/CharacterLib.dart";
import 'package:CreditsLib/src/CharacterObject.dart';
import 'package:RenderingLib/RendereringLib.dart';

Element content = querySelector("#content");

Future<Null> main() async{
    await Loader.preloadManifest();
    CreditsObject co = new CreditsObject("SomethingMemorable","");
    co.makeForm(content);

    CharacterObject co2 = new CharacterObject("John Doe","");
    co2.makeForm(content);

}