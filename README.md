**This is a iPhone application aimed at facilitating the interaction between Doctors examining stroke patients and Specialists that wish to see those patients**
--------------------------------------------------------------------------------
This mobile application works by using a centralized signaling server to facilitate the ability to video chat. It primarily relies on WebRTC. 
Additionally, the application supports iOS push notifications, as well as CallKit.

The goal of this application is to develop one iOS version that can then be ported over to an Apple Vision Pro VR headset

Here are some current screenshots: 

<img src="https://github.com/user-attachments/assets/85548852-4850-4c0b-a99c-86a2d5018a84" width=200>

<img src="https://github.com/user-attachments/assets/a23f4c69-5daa-44e7-baba-eb9c4cc91218" width=200>

<img src="https://github.com/user-attachments/assets/16d00844-50c8-4e5a-93f8-5795cdf6be59" width=200>

<img src="https://github.com/user-attachments/assets/dc4ba9ef-cdd6-415d-971f-bf6227e0f394" width=200>

--------------------------------------------------------------------------------

**How does our application work?**

We use WebRTC to handle the peer2peer video connections. The application connects to a signaling server running a modified version of PeerJS. 
That server tells our application who is calling them and allows us to answer their call. 
Additionally, for our username and password authentication, we plan to use PostGRES in combination with postGREST to create a REST API that will be used for login. 
