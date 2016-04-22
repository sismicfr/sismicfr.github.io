---
title: Retour d'expérience sur l'utilisation intensive de POMM
date: 2016-04-10 20:05
tags:
    - pomm
    - postgresql
    - php
categories:
    - development
    
authors: 
    - Mikael PARIS (https://twitter.com/ParisMikael)
----------------------------------------------------

# Retour d'expérience sur l'utilisation intensive de POMM

## Introduction

Je suis développeur PHP et pationné par les bases données je vais faire un retour sur
  mon expérience sur l'utilisation de POMM en milieu professionnel.
   
Comme beaucoup de développeur PHP j'ai commencé sur MySQL avec de la PDO, un jour on en a marre
d'écrire du SQL et très vite on se retrouve à utiliser un ORM , mon choix s'était porté à 
l'époque sur Propel ( je ne rentrerais pas dans le débas Propel / Doctrine car choisir un d'entre eux 
est déjà un mauvais choix #troll)

A ce moment là une nouvelle vie commence et on se sent léger avec l'impression de se concentrer sur son code métier.
On se sent puissant car à tout moment on peux switcher de base de données sur notre projet. 

C'est génial, mais qui le fait réellement ? 

La deuxième vrai question, qui fait encore du MySql ? :)     

## La découverte de POMM Quésako?

Je dois avouer que la découverte du projet au départ est la résultante d'une micro discussion dans les couloirs du célèbre évènement 
de l'AFUP (le Forum PHP)

Entre temps j'ai stoppé l'utilisation de MySql et dévellopé essentiellement avec Postgres, Pomm est donc devenu une évidence, puisque je ne travaillais 
qu'avec un seul SGBD 

Lorsque je me suis interressé au projet, celui-ci était en v1. La v2 était en cours de développement mais loin d'être en stable. 
J'ai tout de même choisi la v2 pariant sur l'avenir et conseillé par @chanmix51.   
 
J'ai commencé par lire la doc et très vite je compris que Pomm était divisé en plusieurs briques :
    - Foundation
    - ModelManager
    - Cli


## Premiers pas, premiers Doutes

La promesse de Pomm était forte : Utiliser pleinement la puissance de Postgres. Youuuhouu !
 
Sans comprendre réellement le but de la division des packages de Pomm je partis d'un projet Silex et insérais la full stack Pomm.  

Paramétrage du DSN fait et une commande avec le CLI plus tard me voilà dans le Vortex Pomm.
   
L'un des cheval de bataille de POMM est d'être simple et facilement apréhendable, la prise en main a donc été rapide.  

Rapidement je réalise mes premières requêtes avec le ModelManager a base de findByPk et de findWhere.

Puis l'envie me prend soudain de récupérer une liaison grâce a une Foreign Key. Avant j'aurais fait un ->leftJoinFK mais là? 

Hein, je dois écrire une requête SQL? Pendant 2 sec petit moment de solitude, puis rapidement ma mémoire me revient Left Join, Inner Join tant de mot clés non utilisé
depuis bien longtemps.

Après plusieurs années me voilà a ré-écrire mes requêtes SQL. 

Ok super, mais là je passe plus de temps qu'avant à obtenir un résultat identique...

## Changer sa facon de pensée

Bien décidé à découvrir cette puissance promise je lisais en parrallèle des articles sur postgres. 

Le premier d'entre eux me parlais des Schémas, sérieux le truc "public" n'était pas là que pour me rajouter une étape dans le parcours de ma base et faire plus Geek? 

Et bien non! celà a une vrai utilité et certains font le parrallèle avec les namespaces.

Ensuite j'entends parlé de JSON, Hstore, Tsrange, Array... Quoi ? Postgres contiendrais d'autre type de données que integer, varchar... 

Et oui cela fut sans doute mon plus grand boulversement. Ah mais attend, j'ai déjà stocker de l'Array avec Propel ! 
 
En fait les ORM se devant de garder une compatibilité avec tous les SGBD mon array était en fait une string parsée o_O, alors que postgres peut stocker 
en array et grâce a Pomm plus de parsing rien, j'envois et recois un Array à Postgres.

L'autre gros changement à été la découverte da la notion de nested entities (cela fera l'objet d'un autre article)

Bref, je commencais à comprendre qu'il fallait arrété de penser ORM ! et celà est l'étape la plus difficile. 
 
J'aime comparé celà au passage Procédurale => Objet au départ on à l'impression de perdre du temps puis très vite on redécouvre la force des choses, la maintenabilité...

Une de mes erreurs au début à été lors de migration Propel => Pomm d'ommettre la structure de la base de données. Cela n'a finalement aucun intérêt et je 
ne serais que de conseiller uné ré-organisation au moins partiel de votre base.

## La montée en puissance, la re-découverte de Postgres

Mon cerveau commencant à se faire à l'idée je décidais d'en apprendre plus sur Pomm, aider et supporter par la petite mais très présente team du projet.

Dans mes projets je dois souvent mettre en place des tableaux de stats, des graphs etc. Jusqu'à la découverte de POMM cela était une réel corvée.

Je devais écrire des scripts de dizaines de lignes avec l'ORM pour tenter de récupérer des datas sur des dizaines de tables différentes, faires des SUM, des distincts.
Je ne parlerais même pas du débugage de ce genre de script...  

Que dire de la vue ? En effet je me retrouvais avec des objets modélisais qui me servait à rien et mes boucles ressembais à un vrai champs de bataille pour obtenir le résultat.

Et là c'est la découverte de Foundation ! Pourquoi vouloir modélisé en objet ce genre de datas? 

On affiche des tableaux de stats alors pourquoi ne pas faire une simple projection du résultat que l'on souhaite obtenir. Et bien c'est exactement ce que permet Foundation. 

Dans ces tableaux de stats souvent on doit calculer les totaux. Quelle solution ? une autre requête ? calcul lors de la boucle d'affichage?

Pourquoi se faire du mal lorsqu'il existe les [WITH Queries](http://www.postgresql.org/docs/9.4/static/tutorial-window.html) ? 

Je vous laisse également découvrir un article sur les [window functions] (http://www.pomm-project.org/news/a-short-focus-on-window-functions.html)

Une grande étape à été de redonner du sens à mon SGBD en lui re donnant la gestion de certaines contraintes métier. Pourquoi donc écrire des lignes de codes lorsqu'une simple contrainte 
sur Postgres permet de faire la même chose? 

A l'heure des applications format (appli mobile, appli web...) nous multiplions les API pour centraliser les contraintes Métier mais la base de données ne devrait elle pas se satisfaire à elle même et 
posséder les contraintes métier afin de garder son intégrité. 

Feriez vous un script pour controller les Foreign Key ?

## Conclusion

Presque 2 ans se sont écoulés et Pomm fait maintenant partis de mon quotidien déployés en Prod sur du silex, Symfony ou from scratch. Pomm convient à tout type de projet grâce à son découpage.
De grosse appli grâce au Model Manager, des applis ayant besoin d'une interface simple a Postgres grâce au Foundation, mais également des workers grâce au CLI.

Vous l'aurez compris la plus grande difficulté de POMM est la remise en question obligatoire de nos habitudes et la volonté de vouloir arréter de snober le SQL.   

La plus grande force de Pomm est de se faire oublier et de n'avoir aucune contrainte pour communiquer et exploiter la puissance de Postgres.

Aujourd'hui, l'équipe s'est agrandi, la formation a été simple et l'équipe découvre chaque jours des fonctionnalités un peu plus évolués de postgres. 
