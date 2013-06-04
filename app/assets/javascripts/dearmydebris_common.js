
var dearMyDebris={};
dearMyDebris.nextQuery = "";
dearMyDebris.initDebris = function(features)
{
}
dearMyDebris.debris = new Array(0);
dearMyDebris.initialViewPoint = {latitude:35.66193375685752, longitude: 139.67768669128418};
//dearMyDebris.queryBase = "http://192.168.27.149:3000/api/v1/debris/index.json";
dearMyDebris.queryBase = "/api/v1/debris/index.json";
//dearMyDebris.imageDirectoryBaseURL = 'http://192.168.26.160:3000/assets/';
dearMyDebris.imageDirectoryBaseURL = '/assets/';

dearMyDebris.testUserData =
{
  user_name: "chika",
  picture_src: "/assets/follower/chika.png"
};

dearMyDebris.fetchDebris = function(query)
{
  $.get(dearMyDebris.queryBase+query).done(function(ret)
  {
    var newfeatures = ret.feature;
    dearMyDebris.initDebris(newfeatures);
    dearMyDebris.debris = dearMyDebris.debris.concat(newfeatures);
    if (ret.meta !== undefined && ret.meta.next != null)
    {
      setTimeOut(dearMyDebris.fetchData(ret.meta.next), 100);
    }
  });
}

dearMyDebris.getDebrisByID = function(debris_id)
{
  for (var i=0;i<dearMyDebris.debris.length;++i)
  {
    if (dearMyDebris.debris[i].properties.id === debris_id)
    {
      return dearMyDebris.debris[i];
    }
  }
  return null;
}

dearMyDebris.followAction = function(debris_id, user_name)
{
  var debris = dearMyDebris.getDebrisByID(debris_id);
  if (debris != null)
  {
    debris.properties.follower = debris.properties.follower.concat(user_name);
  }
}

dearMyDebris.getContentString = function(debris)
{
  var ret = "";
  var followerstring = "";
  
  ret += "<div id='balloon_window'>" +
    "<div class='balloon_header'>"+
    
        "<h1>" + debris.properties.name + "</h1>";
 // debris.properties.follower.forEach(function(follower, i)
  // {
    // followerstring += follower;
             // ret += "<div id='follower_"+i+"' class='follower'>" +
       // "<img src = 'images/" + follower + ".png'/>" +
	   // "<br />" +
	   // "<p>"+follower+"</p>"+
	   // "</div>";
  // });
  
  ret += "</div><br />";
  
  return ret;
}


dearMyDebris.getContentStringToOver = function(debris)
{
  var ret = "";
  var followerstring = "";
  console.log(debris);
  ret += "<h1 id='debri_name'>" + debris.properties.name + "</h1>"+
  '<div id="debri_followers">';
  debris.properties.follower.forEach(function(follower, i)
  {
    followerstring += follower;
             ret += "<div id='follower_"+i+"' class='follower'>" +
       "<img src = '/assets/follower/" + follower + ".png'/>" +
	   "<br />" +
	   "<p>"+follower+"</p>"+
	   "</div>";
	     });
	   	ret += '</div>'+
	   	'<div >'+
	   	debris.properties.nssdc_catalog.description+
	   	'</div>'+
	   	'<div id="debri_follow_btn">'+
	   '<input id="center_btn" style = "float:left" type="submit" name="button1" value="Follow" onClick="dearMyDebris.followAction(\''+debris.properties.id+'\',\''+dearMyDebris.testUserData.user_name+'\')" />' +
	   '<input id="center_btn" type="submit" name="button1" value="Close" onClick="closeOver()">'+
	   "</div>";
  ret += "<br />";
  

  return ret;
}


