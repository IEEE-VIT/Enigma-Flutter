import 'package:enigma/providers/auth.dart';
import 'package:enigma/providers/profile.dart';
import 'package:enigma/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../size_config.dart';


class ProfileScreen extends StatefulWidget {

  static const routeName = '/profile';
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

Future<Profile> profileData;

const profileUrl = 'https://enigma6-backend.herokuapp.com/api/auth/profile/';

Future<Profile> _getData(String uid) async{
  final response  = await http.post(
    profileUrl,
    headers: {'Authorization': 'Bearer $uid'}
  );
  print(response.body);
  final profile = profileFromJson(response.body);
  return profile;
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    final token = Provider.of<Auth>(context, listen: false).uIdToken;
    profileData = _getData(token);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      drawer: AppDrawer(),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.black
            ),
          ),
          FutureBuilder(
            future: profileData,
            builder: (context, AsyncSnapshot<Profile> snapshot) {
              Widget profileList;
              if (snapshot.hasData){
                profileList =  SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      SizedBox(height: SizeConfig.blockSizeVertical*3,),
                      ProfileTile(snapshot.data.payload.user.name, 'Username'),
                      ProfileTile(snapshot.data.payload.user.email,'Email'),
                      ProfileTile(snapshot.data.payload.user.usedHint.length.toString(), 'Hints Used'),
                      // QUESTIONS SOLVED
                      ProfileCard(snapshot.data.payload.user.level, 'QUESTIONS SOLVED', 'question'),
                      // SCORE
                      ProfileCard(snapshot.data.payload.user.points, 'SCORE', 'score'),
                      //RANK
                      ProfileCard(snapshot.data.payload.user.rank, 'RANK', 'rank')
                    ]
                  ),
                ); 
              }
              else if (snapshot.connectionState == ConnectionState.waiting){
                profileList =  SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical*4),
                      width: SizeConfig.blockSizeHorizontal*10,
                      child: //Text(';p;', style: TextStyle(color: Colors.white),)
                              CircularProgressIndicator()
                      ),
                  ),
                  );
              }
              return CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    backgroundColor: Colors.grey[600],
                    expandedHeight: SizeConfig.screenHeight/4,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.asset('assets/images/hoodie_3.png', fit: BoxFit.cover),
                      title: Padding(
                        padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical*4.25),
                        child: Text('PROFILE', style: TextStyle(
                          fontFamily: 'Saira',
                          fontSize: SizeConfig.blockSizeHorizontal*6
                        ),),
                      ),
                      centerTitle: true,
                    ),
                  ),
                  profileList
                ]
              );
            },
          )
        ],
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  String text;
  String info;
  ProfileTile(this.text, this.info);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(info, style: TextStyle(
        fontSize: SizeConfig.blockSizeHorizontal*4,
        fontFamily: 'Saira',
        color: Colors.green[600]
      ),),
      subtitle: Text(text, style: TextStyle(
        fontFamily: 'Saira',
        fontSize: SizeConfig.blockSizeHorizontal*4,
        color: Colors.white
      ),),
    );
  }
}

class ProfileCard extends StatelessWidget {
  int number;
  String text;
  String image;
  ProfileCard(this.number, this.text, this.image);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
        topRight: Radius.circular(SizeConfig.blockSizeVertical*2),
        topLeft: Radius.circular(SizeConfig.blockSizeVertical*2),
        bottomRight: Radius.circular(SizeConfig.blockSizeVertical*2),
        bottomLeft: Radius.circular(SizeConfig.blockSizeVertical*2),
      )),
      margin: EdgeInsets.all(SizeConfig.blockSizeVertical),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: SizeConfig.screenHeight/4,
            width: SizeConfig.screenHeight/3,
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: SizeConfig.blockSizeVertical*5),
                  Text(number.toString(),
                  style: TextStyle(color: Colors.white, fontSize: SizeConfig.blockSizeVertical*7, fontFamily: 'Saira')
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical*1.6,),
                  Container(
                    height: SizeConfig.blockSizeVertical*4,
                      width: SizeConfig.screenHeight/3.15,
                    child: Card(
                      child: Center(child: Text(text, style: TextStyle(
                        fontFamily: 'Saira',
                        fontSize: SizeConfig.blockSizeVertical*2
                      ),),),
                      color: Color.fromRGBO(97, 247, 147, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0), topRight: Radius.circular(0), bottomLeft: Radius.circular(SizeConfig.blockSizeVertical), bottomRight: Radius.circular(SizeConfig.blockSizeVertical)
                          )
                        ),
                    ),
                  )
                ],
              )
              ),
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/$image.png',))
            ),
          ),
        ],
      ),
      color: Colors.black,
    );
  }
}



