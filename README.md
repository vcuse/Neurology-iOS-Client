**This is a iPhone application aimed at facilitating the interaction between Drs examining stroke patients and Specialists to wish to see those patients**
--------------------------------------------------------------------------------
This mobile application works by using a centralized signaling server to facilitate the ability to video chat. It primarily relies on WebRTC. 
Additionally, the application supports iOS push notifications, as well as CallKit.

The goal of this application is to develop one iOS version that can then be ported over to an Apple Vision Pro VR headset

Here are some current screenshots: 

<img src="https://github.com/user-attachments/assets/d240bbc0-9e27-4436-ae26-4521f8950ec9" width=200 >


<img src="https://github.com/user-attachments/assets/1e847ec3-2655-4e26-80b8-ffe675ab0d2e" width=200>


<img src="https://github.com/user-attachments/assets/3945c927-507a-403e-bba3-d0534290b3b2" width=200>


--------------------------------------------------------------------------------

**How does our application work?**

We use WebRTC to handle the peer2peer video connections. The application connects to a signaling server running a modified version of PeerJS. 
That server tells our application who is calling them and allows us to answer their call. 
Additionally, for our username and password authentication, we plan to use PostGRES in combination with postGREST to create a REST API that will be used for login. 
