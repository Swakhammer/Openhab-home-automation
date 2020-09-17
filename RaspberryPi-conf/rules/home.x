import java.util.Random
//Deklaracja zmiennych - timery
var Timer timer = null
var Timer timer2 = null

rule "Timer do lazienki na 10s"
when
    //gdy przycisk światła w łazience zostanie włączony/wyłączony
    Item bathroom received command
then
    if (receivedCommand == ON) {
        //gdy światło jest włączone to po 10s wyłącza sie
        if (timer === null) {
            timer = createTimer(now.plusSeconds(10)) [|
                sendCommand(bathroom, OFF)
            ]
        } else {
            timer.reschedule(now.plusSeconds(10))
        }
    } else if (receivedCommand == OFF) {
        //gdy światło jest wyłaczone to nic się nie dzieje, a timer zeruje się
        if (timer !== null) {
            timer.cancel
            timer = null
        }
    }
end

//włączanie i wyłączanie światła w sypialni o odpowiednich godzinach
rule "Wlaczanie swiatla w sypialni o 7"
when
    Time cron "0 00 7 ? * * *"
then
    bedroom.sendCommand(ON)
end

rule "Wylaczanie swiatla w sypialni o 23"
when
    Time cron "0 00 23 ? * * *"
then
    bedroom.sendCommand(OFF)
end

//Funkcja umożliwiająca ściemnianie światła w salonie
rule "Sciemnianie swiatel w salonie"
when
    Item livingroom received command
then
if ((receivedCommand == INCREASE) || (receivedCommand == DECREASE)) {
        var Number percent = 0
        if (livingroom.state instanceof DecimalType) percent = (livingroom.state as DecimalType

        if (receivedCommand == INCREASE) percent = percent + 5
        if (receivedCommand == DECREASE) percent = percent - 5

        if (percent < 0)   percent = 0
        if (percent > 100) percent = 100
        postUpdate(livingroom, percent);
    }
    
end

//Wyłączanie wszystkich świateł jednym specjalnym przyciskiem
rule "Wylaczanie wszystkich swiatel"
when
    Item allswitch received command
then
    bathroom.sendCommand(OFF)
    livingroom.sendCommand(OFF)
    bedroom.sendCommand(OFF)
    kitchen.sendCommand(OFF)
end

//Tryb antykradzieżowy
//Uruchamia co 1 minutę wszystkie światła na 5s
rule "Tryb poza domem"
when
    //Jeżeli timer zadziała - co 1 minutę
    Time cron "0 0/1 * 1/1 * ? *"
then
if (holiday.state == ON ) {
    //włączenie wszystkich świateł oprócz łazienki
    sendCommand(kitchen,ON)
    sendCommand(bedroom,ON)
    sendCommand(livingroom,ON)
        if (timer === null) {
            //wyłaczenie po 5s
            timer = createTimer(now.plusSeconds(5)) [|
                sendCommand(kitchen, OFF)
                sendCommand(bedroom,OFF)
                sendCommand(livingroom,OFF)
            ]
        } else {
            timer.reschedule(now.plusSeconds(5))
        }
    } else if (holiday.state == OFF) {
        sendCommand(kitchen,OFF)
        sendCommand(bedroom,OFF)
        sendCommand(livingroom,OFF)
        //reset timerów
        if (timer !== null) {
            timer.cancel
            timer = null
        }
}

end
