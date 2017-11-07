October 2017


WHAT IS CABANON
Cabanon is an experimental visualisation project made by CNIL's Lab and published on the LINC platform.
It aims at exploring issues around privacy and anonymisation techniques by visually comparing the results
obtained by anonymising one dataset with different anaonymisation methods. You can learn more about it here :
https://linc.cnil.fr/fr/cabanon-exploring-and-visualizing-anonymized-datasets
https://linc.cnil.fr/fr/cabanon-un-projet-dexploration-et-de-visualisation-de-donnees-anonymisees

It is built using React.js (https://facebook.github.io/react/) and D3.js (https://d3js.org/).



APP STRUCTURE
You should find the following files and folders in the app :
  - "package.json" : file including all the depencencies and their version used by the visualisation ;
  - "webpack.config.js" : configuration file of the app ;
  - "node_modules" : folder including all the dependencies and libraries used by the app to run it locally ;
  - "public" : folder where the datasets are stored and additional graphic elements ;
  - "src" : folder including all the components and assets forming the visualisation ;



HOW TO RUN LOCALLY THIS APP

- Need to use Node.js 6.9.3 or later (https://nodejs.org/en/) ;
- Need to use npm 3.10.10 (https://www.npmjs.com/) ;
Both can be easily installed on any OS (Windows, macOS, Linux)

Case 1: Running the app and the "node_modules folder" is missing
1. Open the Terminal (macOS) or Command Prompt (Windows) ;
2. Move to the directory "Cabanon-App" using the "cd" (change directory) command ;
3. Make sure you're using Node.js 6.9.3 or later using the command "node -v" and npm 3.10.10 using the command "npm -v".
If needed, install the appropriate version ;
4. Run "npm install". Installing the dependencies might not work if firewalls installed on your network block the download of the libraries.
5. Run "npm start".
6. Start you web browser and go to localhost:8080. The app works in Firefox, Chrome and Safari.

Case 2: Running the app with the "node_modules folder" is present
  1. Open the Terminal (macOS) or Command Prompt (Windows) ;
  2. Move to the directory "Cabanon-App" using the "cd" (change directory) command ;
  3. Make sure you're using Node.js 6.9.3 or later using the command "node -v" and npm 3.10.10 using the command "npm -v".
  If needed, install the appropriate version ;
  4. Run "npm start".
  5. Start you web browser and go to localhost:8080. The app works in Firefox, Chrome and Safari.
