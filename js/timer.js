function format(num) {
    return (num < 10 ? "0" + num : "" + num)
}

window.onload = function () {
    const end = new Date().getTime() + ((45 * 1000 * 60) + 5000) // 45 min
    const timer = document.getElementById("timer")
    let style = "header-inner"
    let lastStyle = style
    var clock = setInterval(function () {
        let now = new Date().getTime()
        let diff = end - now
        console.log(diff)

        if (diff <=0) {
            timer.innerHTML = "⌛ FINISH"
            style = "header-inner alerte"
            clearInterval(clock)
        } else {
            var hours = Math.floor((diff % (1000 * 60 * 60 * 60)) / (1000 * 60 * 60));
            var minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
            var seconds = Math.floor((diff % (1000 * 60)) / 1000);
            if (diff < 5 * 1000 * 60) {
                style = "header-inner alerte"
            } else if (diff < 15 * 1000 * 60) {
                style = "header-inner warning"
            }
            timer.innerHTML = `⏳ ${format(hours)}:${format(minutes)}:${format(seconds)}`
        }
        if (style != lastStyle) {
            timer.className = style
            lastStyle = style
        }
    }, 1000);
}