import 'dart:async';
import 'dart:convert';
import "dart:html";
import "JSONObject.dart";
import "package:RenderingLib/RendereringLib.dart";
import 'package:DollLibCorrect/DollRenderer.dart';
import 'package:CreditsLib/src/StatObject.dart';
class CharacterObject {

    int cardWidth = 400;
    int cardHeight = 525;
    String dollString;
    String name;
    Doll doll;


    TextAreaElement dataBoxElement;
    TextAreaElement dollStringElement;
    TextInputElement nameElement;
    List<StatObject> stats = new List<StatObject>();


    CharacterObject(String this.name, String this.dollString) {
        initializeStats();
        Random rand = new Random();
        doll = Doll.randomDollOfType(1);
    }

    int get seed {
        return 13;
    }

    CharacterObject.fromDataString(String dataString){
        copyFromDataString(dataString);
    }



    void initializeStats() {
        stats.clear();
        Random rand = new Random(seed);
        stats.add(new StatObject(this, StatObject.PATIENCE,StatObject.IMPATIENCE,rand.nextIntRange(StatObject.MINVALUE, StatObject.MAXVALUE)));
        stats.add(new StatObject(this, StatObject.ENERGETIC,StatObject.CALM,rand.nextIntRange(StatObject.MINVALUE, StatObject.MAXVALUE)));
        stats.add(new StatObject(this, StatObject.IDEALISTIC,StatObject.REALISTIC,rand.nextIntRange(StatObject.MINVALUE, StatObject.MAXVALUE)));
        stats.add(new StatObject(this, StatObject.CURIOUS,StatObject.ACCEPTING,rand.nextIntRange(StatObject.MINVALUE, StatObject.MAXVALUE)));
        stats.add(new StatObject(this, StatObject.LOYAL,StatObject.FREE,rand.nextIntRange(StatObject.MINVALUE, StatObject.MAXVALUE)));
        stats.add(new StatObject(this, StatObject.EXTERNAL,StatObject.INTERNAL,rand.nextIntRange(StatObject.MINVALUE, StatObject.MAXVALUE)));
    }

    void copyFromDataString(String dataString) {
        String rawJson = new String.fromCharCodes(BASE64URL.decode(dataString));
        JSONObject json = new JSONObject.fromJSONString(rawJson);
        copyFromJSON(json);
    }

    void copyFromJSON(JSONObject json) {
        dollString = json["dollString"];
        name = json["name"];
        String idontevenKnow = json["stats"];
        loadStatsFromJSON(idontevenKnow);
    }

    void loadStatsFromJSON(String idontevenKnow) {
        if(idontevenKnow == null) return;
        List<dynamic> what = JSON.decode(idontevenKnow);
        //print("what json is $what");
        for(dynamic d in what) {
            //print("dynamic json thing is  $d");
            JSONObject j = new JSONObject();
            j.json = d;
            StatObject s = new StatObject.fromJSONObject(j);
            //don't replace, just overwrite
            for(StatObject s2 in stats) {
                if(s.namePositive == s2.namePositive) {
                    s2.value = s.value;
                }
            }
        }
    }

    String toDataString() {
        String ret = toJSON().toString();
        return BASE64URL.encode(ret.codeUnits);
    }

    JSONObject toJSON() {
        JSONObject json = new JSONObject();
        json["dollString"] = dollString;
        json["name"] = name;

        List<JSONObject> jsonArray = new List<JSONObject>();
        for(StatObject s in stats) {
            //print("Saving ${p.name}");
            jsonArray.add(s.toJSON());
        }
        json["stats"] = jsonArray.toString();


        return json;
    }

    void syncFormToObject() {
        nameElement.value = name;
        dollString = doll.toDataBytesX();
        dollStringElement.value = dollString;

        for(StatObject s in stats) {
            s.syncFormToObject();
        }
        syncDataBox();
    }

    void makeDataStringForm(Element container) {
        DivElement subContainer = new DivElement();
        container.append(subContainer);
        dataBoxElement = new TextAreaElement();
        dataBoxElement.classes.add("creditsFormTextArea");
        dataBoxElement.onChange.listen((e) {
            try {
                syncObjectToDataBox();
            }catch(e) {
                print(e);
                window.alert("error parsing data string, $e");
            }
        });
        subContainer.append(dataBoxElement);
    }

    void makeNameForm(Element container) {
        DivElement subContainer = new DivElement();
        container.append(subContainer);
        LabelElement label = new LabelElement()..text = "Your Name:";
        label.classes.add("creditsFormLabel");
        nameElement = new TextInputElement();
        nameElement.classes.add("creditsFormTextInput");
        nameElement.onInput.listen((Event e) {
            name = nameElement.value;
            syncDataBox();
        });
        subContainer.append(label);
        subContainer.append(nameElement);
    }

    //todo validate doll
    void makeDollForm(Element container) {
        DivElement subContainer = new DivElement();
        container.append(subContainer);
        LabelElement label = new LabelElement()..text = "Your Avatar DollString:";
        label.classes.add("creditsFormLabel");
        dollStringElement = new TextAreaElement();
        dollStringElement.classes.add("creditsFormTextArea");
        dollStringElement.onInput.listen((Event e) {
            dollString = dollStringElement.value;
            //TODO test this with a doll
            syncDataBox();
        });
        subContainer.append(label);
        subContainer.append(dollStringElement);
    }

    void syncDataBox() {
        dataBoxElement.value = toDataString();
    }

    void syncObjectToDataBox() {
        print("going to sync object to data box");
        copyFromDataString(dataBoxElement.value);
        print("going to sync form to data box");
        syncFormToObject();
    }

    void makeForm(Element container) {
        makeViewer(container);
        DivElement subContainer = new DivElement();
        subContainer.classes.add("creditsFormBox");

        DivElement header = new DivElement()..text = "Charactor Creator";
        header.classes.add("creditsFormHeader");
        subContainer.append(header);

        container.append(subContainer);
        makeDataStringForm(header);
        makeNameForm(subContainer);
        makeDollForm(subContainer);
        makeStatForm(subContainer);


        syncFormToObject();
    }

    void makeViewer(Element subContainer) {
        DivElement canvasContainer = new DivElement();
        canvasContainer.classes.add("charViewer");
        subContainer.append(canvasContainer);
        CanvasElement canvas = new CanvasElement(width: cardWidth, height: cardHeight);
        canvasContainer.append(canvas);
        makeViewerBorder(canvas);
        makeViewerDoll(canvas);
        makeViewerText(canvas);
    }

    void makeViewerBorder(CanvasElement canvas) {
        canvas.context2D.fillStyle = "#616161";
        canvas.context2D.strokeStyle = "#3b3b3b";
        int lineWidth = 6;
        canvas.context2D.lineWidth = lineWidth;
        canvas.context2D.fillRect(0, 0, canvas.width, canvas.height);
        canvas.context2D.strokeRect(lineWidth,lineWidth,canvas.width-(lineWidth*2), canvas.height-(lineWidth*2));
    }

    void makeViewerText(CanvasElement canvas) {
        canvas.context2D.fillStyle = "#00ff00";
        canvas.context2D.strokeStyle = "#00ff00";
        int fontSize = 24;
        int currentY = (300+fontSize*2).ceil();

        canvas.context2D.font = "bold ${fontSize}pt Courier New";
        canvas.context2D.fillText("$name",20,currentY);
        fontSize = 18;
        canvas.context2D.font = "bold ${fontSize}pt Courier New";
        currentY += (fontSize*2).round();
        for(StatObject s in stats) {
            canvas.context2D.fillText("${s.name}:",20,currentY);
            canvas.context2D.fillText("${s.value.abs()}",350-fontSize,currentY);

            currentY += (fontSize*1.2).round();
        }
    }

    Future<Null> makeViewerDoll(CanvasElement canvas) async{
        CanvasElement dollCanvas = new CanvasElement(width: doll.width, height: doll.height);
        await DollRenderer.drawDoll(dollCanvas, doll);
        int buffer = 12;
        CanvasElement allocatedSpace = new CanvasElement(width: cardWidth-buffer, height: 300);
        Renderer.drawToFitCentered(allocatedSpace, dollCanvas);
        canvas.context2D.drawImage(allocatedSpace,buffer, buffer);
    }

    void makeStatForm(Element subContainer) {
        DivElement statDiv = new DivElement()..text = "Stats";
        subContainer.append(statDiv);
        for(StatObject s in stats) {
            s.makeForm(statDiv);
        }
    }

}