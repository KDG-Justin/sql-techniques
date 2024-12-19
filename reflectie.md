Milestone 1: Onderwerp en Git
---

Student:
--------
Justin van Leuvenum

Onderwerp: (veel op veel)
-------------------------
- M:N
    - Console - Winkel


- 2Level: Winkel
    - Klant_order
    - Orderlijn


Entiteittypes:
--------------
- Adres
- Bedrijf
- Console
- Levering (tussenentiteit)
- Winkel
- Klant
- Klant_Order
- Orderlijn
- Werknemer

Relatietypes:
-------------
- Bedrijf
    - maakt
    - Console
- Console
    - wordt geleverd door
    - Levering
- Levering
    - wordt geleverd aan
    - Winkel
- Winkel
    - wordt bezocht door 
    - Klant
- Klant
    - maakt
    - Klant_Order
- Klant_Order
    - heeft
    - Orderlijn
- Winkel
    - wordt onderhouden door
    - Werknemer
- Werknemer
    - werkt onder 
    - Manager

- Bedrijf 
    - heeft exact een
    - Adres
- Winkel
    - heeft exact een
    - Adres

Attributen:
-----------
- Bedrijf
    - bedrijf_naam
    - bedrijf_adres
    - bedrijf_land
    - bedrijf_id
- Console
    - console_naam
    - prijs
    - console_id
    - release_datum
- Levering
    - console_id
    - leveringsnummer
    - leveringsadres
    - leveringsdatum
    - winkel_id
    - totale_prijs
- Winkel
    - winkel_naam
    - winkel_id
    - winkel_email
    - stock
    - winkel_telefoon
    - winkel_adres
- Klant
    - klant_naam
    - klant_leeftijd
    - klant_adres
    - klant_id
- Klant_Order
    - order_id
    - order_prijs
    - klant_id
- Werknemer
    - werknemer_voornaam
    - werknemer_achternaam
    - werknemer_id
    - is_manager
- Orderlijn
    - orderlijn_id
    - console_id
    - aantal
    - prijs
- Adres
    - straat
    - nummer
    - postcode