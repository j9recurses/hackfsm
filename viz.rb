#!/usr/bin/env ruby
 
require 'rubygems'
require 'sinatra'
 
get '/' do
  erb :index
end
 
get '/follower_viz' do
  @user = params[:user]
  erb :follower
end
 
get '/repo_viz' do
  @user = params[:user]
  erb :repo
end
 
__END__
 
@@ index
<html>
  <head>
    <meta http-equiv="content-type" content="text/html;charset=utf-8">
    <title>githubviz</title>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
    <script type="text/javascript">
      $(function (){
        $('#viz_form').submit(function(ev){
          //this happens if form is submitted
          //prevent the default behavior of a form (it should do nothing in our case)
          ev.preventDefault();
 
          //send an ajax request to our action
          $.ajax({
            url: "/follower_viz",
            //serialize the form and use it as data for our ajax request
            data: $(this).serialize(),
            //the type of data we are expecting back from server, could be json too
            dataType: "html",
            success: function(data) {
              //if our ajax request is successful, replace the content of our viz div with the response data
              $('#viz').html(data);
            }
          });
 
          //show the link to the repo_viz (don't forget: we are still in the submit event!)
          $('#viz_link').append($("#viz_form input:first").val());
          $('#viz_p').show();
        });
 
        $('#viz_link').click(function(ev){
          //this happens if we click our new shiny link with the submitted username in it
 
          //do you remember?! :)
          ev.preventDefault();
 
          $.ajax({
            url: "/repo_viz",
            data: "user="+$("#viz_form input:first").val(),
            dataType: "html",
            success: function(data) {
              $('#viz').html(data);
            }
          });
 
        });
      });
    </script>
  </head>
  <body>
    <form action="/" method="post" id="viz_form">
      <label>Enter your username:</label>
      <input name="user" type="text">
      <input type="submit" value="Do it!">
    </form>
    <p id="viz_p" style="display:none;"><a id="viz_link" href="#">click here if you want to see the awesome repo_viz for </a></p>
    <div id="viz" style="margin:20px;border:1px dashed black;height:400px;">
    </div>
  </body>
</html>
 
@@ follower
<p>here comes the crazy follower_viz for <%= @user %></p>
 
@@ repo
<h1>this viz from <%= @user %>'s repos is HUGE!</h1>