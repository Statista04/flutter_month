RaisedButton(
onPressed: () => StateWidget.of(context).signInWithGoogle(),
padding: EdgeInsets.only(top: 3.0, bottom: 3.0, left: 3.0),
color: const Color(0xFFFFFFFF),
child: new Row(
mainAxisSize: MainAxisSize.min,
children: <Widget>[
new Image.asset(
'asset/google_button.jpg',
height: 40.0,
),
new Container(
padding: EdgeInsets.only(left: 10.0, right: 10.0),
child: new Text(
"Sign in with Google",
style: TextStyle(
color: Colors.grey,
fontWeight: FontWeight.bold),
)
),
],
),
)