---
title: Notification des erreurs applicatives vers Slack via Monolog
date: 2016-04-10 20:05
tags:
    - slack
    - monolog
categories:
    - development
    
authors: 
    - Laurent BOLZER (https://twitter.com/ryosaeba_fr)
---

# Notification des erreurs applicatives vers Slack via Monolog

## Le contexte

Chez [Sismic](https://sismicfr.github.io), nous sommes tous en télétravail. 
Nous avons donc besoin d'un outil de communication nous permettant d'échanger entre nous sur différents sujets, que ce soit sur les projets en cours, l'organisation, 
les plannings ou tout autre sujet de discussion. Il faut également que nous ayions accès à l'historique des communications des membres de l'équipe,
 même lorque nous sommes hors ligne (ce qui bien entendu ne devrait jamais arriver :D). 
  
C'est pour cette raison que nous avons opté pour [Slack](https://slack.com). 


Nous développons des applications [Symfony 2] (http://symfony.com) pour nos différents clients, avec [Monolog](https://github.com/Seldaek/monolog) pour la gestion des logs applicatifs. 
Lorsqu'une erreur arrive sur une de nos applications, elle est enregistrée dans le fichier log du projet. 

Malheureusement, les fichiers logs sont généralement consultés par nos équipes seulement après que l'erreur nous ait été signalée, que ce soit par les clients ou bien par un internaute. 
Une première solution a été de mettre en place une notification par mail, seulement cette solution a vite trouvé ses limites lors du départ en vacances du premier développeur :).


## Envoyer les notifications d'erreurs de nos applications vers un channel Slack via Monolog
 
Pour gagner en réactivité, il nous faut donc pouvoir récupérer en temps réel les notifications d'erreur sur un canal de communication accessible à n'importe quel moment 
par l'équipe de développement. 
Nous avons justement ce canal de communication à notre disposition: notre outil de communication Slack. Chaque membre de l'équipe de développement s'y connecte en début de journée et 
est connecté durant toute sa journée de travail (et même plus si affinité! ). Il aurait donc été intéressant de pouvoir utiliser également cet outil pour recevoir les erreurs critiques de nos applications. 

Ca tombe bien, Monolog dispose d'un [handler Slack](https://github.com/Seldaek/monolog/blob/master/doc/02-handlers-formatters-processors.md#send-alerts-and-emails) 
qui permet d'envoyer les erreurs ayant un certain niveau de criticité minimum vers un channel Slack pré-défini: 
[https://github.com/Seldaek/monolog/blob/master/src/Monolog/Handler/SlackHandler.php](https://github.com/Seldaek/monolog/blob/master/src/Monolog/Handler/SlackHandler.php)
 
Voici les étapes pour le paramétrage de cette fonctionnalité : 
 
- Créer un nouveau channel Slack 
Il faut se rendre sur [la page de création de channel](https://get.slack.help/hc/en-us/articles/201402297-Creating-a-channel) et créer un nouveau channel privé. 

- Générer un token d'identification pour autoriser notre application Symfony (ou toute autre application utilisant Monolog pour enregistrer ses logs) à envoyer des données à Slack. 
[Authentication](https://api.slack.com/web)

- Paramétrer la communication entre Slack et Monolog dans config_prod.yml (config_dev.yml pour tester en développement). 

`parameters.yml`

    parameters:
        slack_token: slack-token
        slack_channel: "#nom-du-channel-slack"
        slack_bot: nom-du-bot-slack
        slack_emoji: :logo-a-utiliser:
        slack_level: error # Niveau d'erreur minimum qui enverra une notification au channel Slack

`config_xxx.yml `

    monolog:
        handlers:
            slack:
                type:       slack
                token:       %slack_token%
                channel:     %slack_channel%
                bot_name:    %slack_bot%
                icon_emoji:  %slack_emoji%
                level:       %slack_level%
                include_extra: true

- Et l'appel de l'erreur dans l'application: 


    $this->get('logger')->error('Error Message', [
        'parameter1' => 'value1',
        'parameter2' => 'value2',
        'parameter3' => 'value3',
        'parameter4' => 'value4',
    ]);


## Conclusion

Voilà, j'espère que désormais vous pourrez être notifiés rapidement d'une erreur sur votre application si vous utilisez Monolog et Slack. 




