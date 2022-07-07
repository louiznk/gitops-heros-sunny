function format(num) {
    return (num < 10 ? "0" + num : "" + num)
}

window.onload = function () {
    const end = new Date().getTime() + ((50 * 1000 * 60) + 5000) // 50 min + 5s start time
    const timer = document.getElementById("timer")
    let style = "header-inner"
    let lastStyle = style
    let clock = setInterval(function () {
        let now = new Date().getTime()
        let diff = end - now

        if (diff <=0) {
            timer.innerHTML = "⌛ FINISH"
            style = "header-inner finish"
            sound='sounds/boat_horn.mp3'
            clearInterval(clock)
        } else {
            let hours = Math.floor((diff % (1000 * 60 * 60 * 60)) / (1000 * 60 * 60));
            let minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
            let seconds = Math.floor((diff % (1000 * 60)) / 1000);
            if (diff < 5 * 1000 * 60) { // 5
                style = "header-inner alerte"
                sound='sounds/bell_gong.mp3'
            } else if (diff < 15  * 1000 * 60) { // 15
                style = "header-inner warning"
                sound='sounds/clock_timer.mp3'
            }
            timer.innerHTML = `⏳ ${format(hours)}:${format(minutes)}:${format(seconds)}`
        }
        if (style != lastStyle) {
            timer.className = style
            lastStyle = style            
            let audio=new Audio(sound)
            audio.play()
        }
    }, 1000);
}