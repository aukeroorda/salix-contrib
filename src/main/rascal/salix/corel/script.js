function initializeRecipe() {
	defs = document.querySelectorAll('[data-ingredient-def]');

	for (def of defs)
	{
	use_selector = `[data-ingredient-ref='${def.dataset.ingredientDef}']`;
	uses = document.querySelectorAll(use_selector);
	
	let current_def = def;
	for (use of uses)
	{
		use.addEventListener('focus', (event) => {
		event.target.classList.add('ingredient_highlight');
		current_def.classList.add('ingredient_highlight');
		});

		use.addEventListener('blur', (event) => {
		event.target.classList.remove('ingredient_highlight');
		current_def.classList.remove('ingredient_highlight');
		});
	}
	
	let current_uses = uses;
	def.addEventListener('focus', (event) => {
		event.target.classList.add('ingredient_highlight');
		for (current_use of current_uses)
		{
		current_use.classList.add('ingredient_highlight');
		}
	});
	
	def.addEventListener('blur', (event) => {
		event.target.classList.remove('ingredient_highlight');
		for (current_use of current_uses)
		{
		current_use.classList.remove('ingredient_highlight');
		}
	});
	}

	timers = document.querySelectorAll('.timer[data-original-time]');

	for (const timer of timers)
	{
		// Click: pause/play
		// Dblclick: reset + pause
		let is_playing = false;
		
		timer.addEventListener('click', (event) => {
			is_playing = !is_playing;
			if (timer.dataset.currentTime > 0)
			{
				beep();
			}
			
			
			if (timer.dataset.currentTime <= 0)
			{
				is_playing = false;
				getSelection().empty();
				timer.dataset.currentTime = timer.dataset.originalTime;
				timer.classList.remove('timer_highlight');
				
				time_field = timer.querySelector('.time_value');
				time_field.innerHTML = time_field.dataset.originalText;
			}
		});
		
		current_timer = setInterval(function() {
			if (is_playing)
			{
				timer.dataset.currentTime -= 1;
				time_field = timer.querySelector('.time_value');
				time_field.innerHTML = pretty_print(timer.dataset.currentTime);
				
				if (timer.dataset.currentTime <= 0) {
					beep();
					timer.classList.add('timer_highlight');
				}
			}
			}, 1000);
		
		timer.addEventListener('dblclick', (event) => {
			is_playing = false;
			getSelection().empty();
			timer.dataset.currentTime = timer.dataset.originalTime;
			timer.classList.remove('timer_highlight');
			
			time_field = timer.querySelector('.time_value');
			time_field.innerHTML = time_field.dataset.originalText;
		});
	}
};
initializeRecipe();

function pretty_print(s)
{
	time = Math.abs(s);
	prefix = (s < 0) ? '-' : ''; 

	var h = Math.floor(time / 3600).toString();
	var m = Math.floor(time % 3600 / 60).toString();
	var s = Math.floor(time % 60).toString().padStart(2,'0');
	if (h == '0')
	{
		return prefix + m + ':' + s;
	}
	
	m.padStart(2,'0');
	return prefix + h + ':' + m + ':' + s;
}

// Thanks to https://stackoverflow.com/a/29641185/3684659
//if you have another AudioContext class use that one, as some browsers have a limit
var audioCtx = new (window.AudioContext || window.webkitAudioContext || window.audioContext);

//All arguments are optional:

//duration of the tone in milliseconds. Default is 1000
//frequency of the tone in hertz. default is 440
//volume of the tone. Default is 1, off is 0.
//type of tone. Possible values are sine, square, sawtooth, triangle, and custom. Default is sine.
//callback to use on end of tone
function beep(duration, frequency, volume, type, callback) {
    var oscillator = audioCtx.createOscillator();
    var gainNode = audioCtx.createGain();

    oscillator.connect(gainNode);
    gainNode.connect(audioCtx.destination);

    if (volume){gainNode.gain.value = volume;}
    if (frequency){oscillator.frequency.value = frequency;}
    if (type){oscillator.type = type;}
    if (callback){oscillator.onended = callback;}
    
    gainNode.gain.value = 0.00001;
    gainNode.gain.exponentialRampToValueAtTime(1, audioCtx.currentTime+0.1);
    oscillator.start(audioCtx.currentTime);
    gainNode.gain.exponentialRampToValueAtTime(0.00001, audioCtx.currentTime + 2);
    oscillator.stop(audioCtx.currentTime + ((duration || 1000) / 1000));
};
