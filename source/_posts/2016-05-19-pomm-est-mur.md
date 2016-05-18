---
title: Retour d'expérience: Pomm est mûr, abandonnons les ORM
date: 2016-05-19 08:00
tags:
    - pomm
    - PostgreSQL
    - php
categories:
    - development
    
authors: 
    - Mikael PARIS (https://twitter.com/ParisMikael)
---

# L'abandon d'un ORM au profit de Pomm, retour d'expérience.

## Introduction

Chez Sismic, nous utilisons Pomm sur tous nos projets. Je vais vous retracer les étapes qui ont constituées
notre passage de Propel (ORM) vers Pomm.
   
Comme beaucoup de développeurs PHP, j'ai débuté avec MySQL et PDO. Les projets se succèdent, un jour on est lassé
d'écrire du SQL et très vite on se retrouve à utiliser un ORM.

A ce moment là une nouvelle vie commence, on se sent léger et puissant avec l'impression de pouvoir se concentrer sur son code métier.

L'ORM possède de nombreux avantages, l'un des principaux étant de pouvoir s'interfacer avec plusieurs SGBD. 

Seulement, cet avantage est également sa plus grande faiblesse. En effet pour garantir une parfaite compatibilité, il est obligé d'utiliser des fonctionnalités communes, et donc de faire l'impasse sur certaines spécificités propres à tel ou tel moteur de base de données qui n'éxistent pas partout.

Si cela n'est pas dommageable pour Mysql, c'est bien différent avec PostgreSQL.   

## La découverte de Pomm, QUÉSACO ?

L'essayer, c'est l'adopter. C'est un peu le résumé de mon passage de Mysql vers PostgreSQL. Au fil du temps, l'envie d'en découvrir plus sur ce SGBD se fait ressentir.

Une envie très vite rendue impossible, à cause des limitations de l'ORM #frustration.

C'est lors d'une discussion dans les couloirs du célèbre évènement de l'[AFUP](http://www.afup.org) (le Forum PHP) que j'ai découvert le projet Pomm

Lorsque je m'y suis interressé, celui-ci était encore en v1, la v2 étant alors en cours de développement. 
J'ai tout de même choisi cette dernière, pariant sur l'avenir mais également conseillé par [Grégoire Hubert - @chanmix51](https://twitter.com/chanmix51), owner de Pomm.


## Premiers pas, premiers Doutes

La promesse de Pomm était forte : Utiliser pleinement la puissance de Postgres. Youuuhouu !
 
Pomm est divisé en plusieurs briques :  
    - Foundation
    - ModelManager
    - Cli
 
Sans comprendre réellement le but de cette division, je commençais avec un projet Silex et insérais la full stack Pomm.  
   
L'un des chevaux de bataille du projet étant de se vouloir simple et facilement appréhendable, la prise en main a été très rapide.  

Je paramètre le DSN, exécute une commande avec le CLI et me voilà dans le Vortex Pomm.

Rapidement, je réalise mes premières requêtes avec le ModelManager pour effectuer les fonctions de CRUD classiques : findByPk, findWhere...

Puis l'envie me prend soudain de récupérer une liaison grâce à une Foreign Key. Avec Propel j'aurais fait un ->leftJoinFK mais là? 

Quoi? je dois écrire une requête SQL? 

Pendant 2 secondes, un petit moment de solitude me gagne... Puis, rapidement, la mémoire me revient: Left Join, Inner Join, tant de mots clés non utilisés depuis bien longtemps!

Après plusieurs années, me voilà à réecrire mes requêtes SQL ! 

C'est génial, mais là je passe plus de temps qu'avant à obtenir un résultat identique ... Dans ce cas, quel avantage Pomm m'apporte t'il ?

## Changer sa façon de penser

Bien décidé à utiliser pleinement cette puissance promise, je lisais en parallèle des articles sur PostgreSQL. 

Le premier d'entre eux me parlait des Schémas. J'ai découvert que "public" n'était pas là que pour ajouter une étape dans le parcours d'accès à ma base et faire plus Geek que Mysql ^^ ? 

Et bien non! celà a une vraie utilité, dont voici le détail [schémas PostgreSQL](http://docs.postgresqlfr.org/9.4/ddl-schemas.html). 

Ensuite j'entend parler de JSON, Hstore, Tsrange, Array... PostgreSQL contiendrait donc d'autres types de données que integer, varchar... ?

Cela fut sans doute mon plus grand bouleversement. Stop ! j'ai déjà stocké de l'Array avec Propel ! 
 
En fait les ORM se devant de garder une compatibilité avec tous les SGBD, mon array était en fait stocké sous la forme d'une chaîne parsée o_O. PostgreSQL, lui, peut stocker réellement un array et grâce a Pomm plus besoin de parsing. J'envoie et reçois un Array à Postgres.

Je commencais à comprendre qu'il fallait arréter de penser ORM ! et celà fût sans doute l'étape la plus difficile. 
 
Je compare celà au passage Procédural => Objet. Au départ, on a l'impression de perdre du temps puis très vite on découvre la force des choses, la maintenabilité...

Lors de mes tests pour intégrer Pomm à mes projets existants avec Propel, une de mes premières erreurs fut de négliger la structure de la base de données. Conserver une struture de base de données dictée par l'utilisation d'un ORM (Propel, Doctrine ou autre) couplée avec Pomm ne présente finalement aucun intéret et je ne saurais que trop vous conseiller uné ré-organisation au moins partielle de votre base.

## La montée en puissance, la re-découverte de Postgres

Mon cerveau commencant à se faire à l'idée, je décidais d'en apprendre plus sur Pomm, aider et supporter par la petite mais très présente team du 
projet sur le channel IRC : irc.freenode.net #pomm.

Dans mes projets, je dois souvent mettre en place des tableaux de statistiqures, des graphiques etc... Jusqu'à la découverte de Pomm, cela était une réelle corvée.

Je devais écrire des scripts de plusieurs lignes avec l'ORM pour tenter de récupérer des datas sur des dizaines de tables différentes et faire des SUM, des distincts...

Ce genre de script est très peu debuggable et maintenable, et que dire de l'exploitation des résultats obtenus ? 
Des boucles imbriquées et des conditions en tout genre pour tenter d'obtenir quelque chose d'exploitable.

C'est là qu'intervient Foundation ! Pourquoi vouloir modéliser en objet ce genre de données ? 

Ce que l'on souhaite, c'est afficher des tableaux de stats. Alors pourquoi ne pas faire une simple projection du résultat que l'on veut obtenir? 
C'est exactement ce que permet Foundation en bénéficiant des avantages de Pomm. 

Dans ces tableaux de statistiques, on doit souvent calculer les totaux. Quelle solution ? une autre requête ? calcul des totaux lors de la boucle d'affichage?
Pourquoi faire compliqué lorsque c'est déjà disponible en natif avec les [WITH Queries](http://www.PostgreSQL.org/docs/9.4/static/tutorial-window.html) ? 

Une grande étape a été de redonner du sens à mon SGBD en lui intégrant la gestion de certaines contraintes métier, notamment grâce à des triggers.  

Le but étant de permettre à la base de données de pouvoir garder son "intégrité métier" de manière autonome, peu importe le client qui interragit avec elle. 

## Conclusion

Presque 2 ans se sont écoulés et Pomm fait maintenant partie de notre quotidien et est déployé en production sur des projets Silex, Symfony2 & Symfony3 ou from scratch. 

Chez Sismic, Pomm nous a permis de gagner en efficacité. Notre code est beaucoup plus maintenable et évolutif.

Cela à également permis de réduire considérablement le temps de formation lors de nouveau recrutement et de réduire la prise en main des projets.

Pomm convient à tout type de projet grâce à son découpage:
Des applications complexes grâce au Model Manager, des applications ayant besoin d'une interface simple a PostgreSQL grâce à Foundation, mais également des workers grâce au CLI.

Vous l'aurez compris, la plus grande difficulté de Pomm est la remise en question obligatoire de nos habitudes et la volonté de vouloir arréter de snober le SQL.   

La plus grande force de Pomm est de se faire oublier et de n'avoir aucune contrainte pour communiquer et exploiter la puissance de PostgreSQL.

Aujourd'hui, l'équipe s'est agrandie, la formation a été simple et l'équipe découvre chaque jour des fonctionnalités un peu plus avancées de Postgres. 
