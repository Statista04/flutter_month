import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() => runApp(MyApp());

class StateWidget extends StatefulWidget {
  final StateModel state;
  final Widget child;

  StateWidget({
    @required this.child,
    this.state,
  });

  static _StateWidgetState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_StateDataWidget)
    as _StateDataWidget)
        .data;
  }

  @override
  _StateWidgetState createState() => new _StateWidgetState();
}

class _StateWidgetState extends State<StateWidget> {
  StateModel state;
  GoogleSignInAccount googleAccount;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  @override
  void initState() {
    super.initState();
    if (widget.state != null) {
      state = widget.state;
    } else {
      state = new StateModel(isLoading: true);
      initUser();
    }
  }

  Future<Null> initUser() async {
    googleAccount = await getSignedInAccount(googleSignIn);
    if (googleAccount == null) {
      setState(() {
        state.isLoading = false;
      });
    } else {
      await signInWithGoogle();
    }
  }

  Future<Null> signInWithGoogle() async {
    if (googleAccount == null) {
      // Start the sign-in process:
      googleAccount = await googleSignIn.signIn();
    }
    FirebaseUser firebaseUser = await signIntoFirebase(googleAccount);
    state.user = firebaseUser; // new user
    setState(() {
      state.isLoading = false;
      state.user = firebaseUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new _StateDataWidget(
      data: this,
      child: widget.child,
    );
  }
}

class _StateDataWidget extends InheritedWidget {
  final _StateWidgetState data;
  _StateDataWidget({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_StateDataWidget old) => true;
}
class StateModel {
  bool isLoading;
  FirebaseUser user;
  StateModel({
    this.isLoading = false,
    this.user,
  });
}

Future<GoogleSignInAccount> getSignedInAccount(
    GoogleSignIn googleSignIn) async {
  GoogleSignInAccount account = googleSignIn.currentUser;
  if (account == null) {
    account = await googleSignIn.signInSilently();
  }
  return account;
}

Future<FirebaseUser> signIntoFirebase(
    GoogleSignInAccount googleSignInAccount) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignInAuthentication googleAuth =
  await googleSignInAccount.authentication;
  print(googleAuth.accessToken);
  return await _auth.signInWithGoogle(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
}


Widget _buildContent() {
  if (appState.isLoading) {
    return _buildLoadingIndicator();
  } else if (!appState.isLoading && appState.user == null) {
    return new LoginScreen();
  } else {
    return _buildHomeScreen();
  }
}

@override
Widget build(BuildContext context) {
  // Build the content depending on the state:
  appState = StateWidget.of(context).state;
  return _buildContent();
}
}


Widget _buildHomeScreen({Widget body}) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.black87,
      title: Text('Home Screen'),
    ),
    body: Container(
      child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                  padding: EdgeInsets.all(20.0),
                  height: 150.0,
                  width: 150.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(appState.user.photoUrl.toString()),
                    ),
                  )),
              new Text(
                'Hello, ' '${appState.user.displayName}' ' !',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 25),
              )
            ],
          )),
    ),
  );
}