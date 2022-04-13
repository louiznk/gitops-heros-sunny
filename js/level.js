let issues = 0
let storyPoints = 0

const labelContainer = document.getElementById("label-container")
const labelLevel = document.getElementById("label-level")
const finalScore = document.getElementById("final-score")

function resolveAndGo(link, issuesResolved, difficulty) {
    resolve(issuesResolved, difficulty)
    location.assign(link)
}

function resolve(issuesResolved, difficulty) {
    let lastLevel = getLevel(storyPoints)
    issues += issuesResolved
    storyPoints += difficulty

    let newLevel = getLevel(storyPoints)

    if (lastLevel < newLevel) {
        // level up
        labelLevel.innerHTML = '💪🆙'
        labelLevel.className = 'show lvl-up';
        labelContainer.className = 'show header-inner'
        setTimeout(function () {
            labelLevel.className = 'hide lvl-up';
        }, 2000);
    } else if (lastLevel > newLevel) {
        // level down
        labelLevel.innerHTML = '🤢🔽'
        labelLevel.className = 'show lvl-down';
        labelContainer.className = 'show header-inner'
        setTimeout(function () {
            labelLevel.className = 'hide lvl-down';
        }, 2000);
    }
    // TODO lvl down

    labelContainer.innerHTML = `Level : ${newLevel} (issues : ${issues}, points : ${storyPoints})`
    labelContainer.className = 'show header-inner';

    finalScore.innerHTML = `Félicitation, vous avez résolue ${issues} issues et ${storyPoints} story points<br \>Vous finissez l'aventure avec le niveau ${newLevel}`

}

// fib like...
const fibonacci = [1, 3, 5, 8, 13, 21, 34, 55]


function getLevel(points) {

    const nextValue = fibonacci.find(element => element > points)
    const index = fibonacci.indexOf(nextValue)
    if (index > 1) {
        return index - 1
    } else {
        return 0
    }
}
