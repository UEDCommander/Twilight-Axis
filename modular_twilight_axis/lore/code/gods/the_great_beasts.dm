/datum/faith/inhumen/gronn
	name = "The Great Beasts"
	translated_name = "Великие Звери"
	desc = "<b>Религия Гронна</b> резко отличается от доминирующих форм культа в «цивилизованном» мире Гримории. За долгие столетия выживания в тундре она трансформировалась в анимистическую систему, сосредоточенную на духах природы и <b>Зверях</b>, каждый из которых воплощает строгое, но необходимое уроком качество.\n\
	Гроннцы знают истинные имена богов Гримории, но произносят их крайне редко и только в отчаянных обстоятельствах, прекрасно понимая риск привлечь разрушительное внимание высших сил. Несмотря на определённые параллели в образах и доменах, гроннская религия отвергает принадлежность к культам Спасения, Святой Экклезиархии и учению Десяти, рассматривая их как чуждые и опасные системы веры."
	worshippers = "Кланы народа Гронна."
	godhead = /datum/patron/inhumen/graggar/moose
	required_origins = list(/datum/virtue/origin/gronn)

/datum/patron/inhumen/zizo/wolf
	name = "The Plotting Volf"
	translated_name = "Волчица, Замышляющая"
	rusgodnames = list(
		"Волчица", "Волчицы", "Волчице", "Волчицу", "Волчицей", "Волчице",
		"Замышляющая", "Замышляющей", "Замышляющей", "Замышляющую", 
		"Замышляющей", "Замышляющей"
)

	domain = "Охота, изучение добычи, мудрость предков, возвышение тебя и твоего рода."
	desc = "Волчица с взъерошенной шерстью и холодными глазами. Её живот навсегда разодран, кровоточит, и исписан зловещими рунами.\n\
	Прошлое потеряно, но за завесой саг таится правда о зверях и магии, что уходят корнями в тёмные времена. Когда-то у неё отняли детей. Она не позволит, чтобы это повторилось.\n\
	Волчица требует от своего народа учиться у предков. Внимательно слушать старые саги, выискивая в них предостережения и уроки, что предки вложили в слова и образы. Познавать мир, приспосабливаться, переживать морозы и все испытания, которые бросает природа.\n\
	Но знай: твой покой не вечен. Шаманы рано или поздно вернут тебя из кургана, чтобы ты передал свою мудрость или встал рядом с живыми в час нужды. Таков её последний дар и её последнее требование."
	associated_faith = /datum/faith/inhumen/gronn
	crafting_recipes = list()
	worshippers = "Хранители рода и знаний, охотники, амбициозные ярлы."
	confess_lines = list(
		"ДУХИ ПРЕДКОВ ЗАЩИТЯТ МЕНЯ!",
		"Я СЛЕДУЮ ЗОВУ ВОЛЧИЦЫ!",
		"УБЕЙ МОЕ ТЕЛО, И ВОЛЧИЦА УБЕРЕЖЕТ МОЙ ДУХ!",
	)

/datum/patron/inhumen/zizo/spider
	name = "The Rising Spider"
	translated_name = "Паучиха, Восстающая"
	rusgodnames = list(
		"Паучиха", "Паучихи", "Паучихе", "Паучиху", "Паучихой", "Паучихе",
		"Восстающая", "Восстающей", "Восстающей", "Восстающую", 
		"Восстающей", "Восстающей"
)

	domain = "Жертва, очищение через боль, спасение остатка, долг, переплетение судеб, болезненное исцеление."
	desc = "Огромная паучиха с обугленным, местами истлевшим хитином, будто вытащенная из кострища. Её многочисленные глаза запаяны мутной серебристой плёнкой, а из трещин панциря тянутся тонкие, похожие на сухожилия нити, которыми она шевелит мёртвым и живым. Там, где Волчица возвращает предка ради совета, Паучиха удерживает его дольше — пока её сеть не будет завершена.\n\
	Этот мир болен, и болезнь не выжечь без боли — так учат её жрицы. Паучиха требует принимать страдание как цену спасения: часть дерева должна сгнить, чтобы ствол выжил. Она благоволит тем, кто готов жертвовать собой и малым числом ради клана, но презирает тех, кто прячется за чужой болью.\n\
	Живи, как нить в сети — натянуто, но не до разрыва. Ищи меру между фанатизмом и бездействием: чрезмерная мягкость так же преступна, как жестокость ради забавы. Смерть для неё не конец, а переход в новый узел: тех, кого она сочтёт нужными, Паучиха не отпускает в покой, а прячет в своих коконах до часа, когда их боль снова пригодится.\n\
	Но помни её предупреждение: не всякий крик о спасении следует слышать. Если ты хватишься за каждого тонущего, сеть порвётся и утонут все. За лишнюю жалость и пустую жестокость Паучиха карает одинаково — рвёт нить, оставляя душу болтаться в пустоте, где нет ни клана, ни богов, ни конца страдания."
	associated_faith = /datum/faith/inhumen/gronn
	crafting_recipes = list()
	worshippers = "Целители, изгои."
	confess_lines = list(
		"ПАУЧИХА СПАСЁТ НАС ОТ СТРАДАНИЙ!",
		"ХВАЛА ПАУЧИХЕ!",
		"ПОЖЕРТВУЙ МНОЙ, ВОССТАЮЩАЯ!",
	)

/datum/patron/inhumen/graggar/moose
	name = "The Grinning Moose"
	translated_name = "Лось, Скалящийся"
	rusgodnames = list(
		"Лось", "Лося", "Лосю", "Лося", "Лосем", "Лосе",
		"Скалящийся", "Скалящегося", "Скалящемуся", "Скалящегося", 
		"Скалящимся", "Скалящемся"
	)

	domain = "Битва, сражение, насилие, иерархия, триумф, победа, почётная слава."
	desc = "Огромный лось, истерзанный и кровоточащий. Победи врага или пади вместе с ним. Лось требует от его народа быть сильными, чтобы выживать в суровом климате. Лось не покровительствует слабым и трусливым, воплощая мощь, необходимую, чтобы выжить в морозах и отнять то, что нужно, у природы и у других.\n\
	Но даже он сам когда-то пал в битве. Поэтому нельзя терять себя в ярости и убивать без причины — иначе и ты тоже сгинешь, как Лось, и твоя душа окажется нанизанной на его рога. "
	associated_faith = /datum/faith/inhumen/gronn
	crafting_recipes = list()
	worshippers = "Ярлы, шаманы, налетчики."
	confess_lines = list(
		"ВЕЛИКИЙ ЛОСЬ ВЕДЕТ МЕНЯ К СЛАВЕ!",
		"ЛОСЬ ПРОНЗИТ ТВОЮ ДУШУ!",
		"Я СМЕЮСЬ В ЛИЦО СМЕРТИ, КАК ВЕЛИКИЙ ЛОСЬ СМЕЯЛСЯ НАД НЕЙ!",
	)
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison							= CLERIC_ORI,
					/obj/effect/proc_holder/spell/self/graggar_bloodrage/gronn					= CLERIC_T0,
					/obj/effect/proc_holder/spell/self/graggar_chainbreak/gronn					= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 							= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_heal							= CLERIC_T1,
					/obj/effect/proc_holder/spell/self/graggar_call_to_slaughter/gronn 			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/projectile/graggar_blood_net/gronn 	= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/silence/graggar						= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/revel_in_slaughter/gronn 				= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/resurrect/graggar						= CLERIC_T4,
	)

/datum/patron/inhumen/matthios/bear
	name = "The Starving Bear"
	translated_name = "Медведь, Голодающий"
	rusgodnames = list(
		"Медведь", "Медведя", "Медведю", "Медведя", "Медведем", "Медведе",
		"Голадающий", "Голадающего", "Голодающему", "Голодающего", 
		"Голодающим", "Голодающем"
	)

	domain = "Голод, стужа, нужда, надвигающийся мороз."
	desc = "Дикий медведь с глазами, горящими солнечным огнём. Его шкура усеяна искрами золота в форме шипов.\n\
	Голод вечен: сколько Медведя ни корми — он всегда потребует большего. Золота, еды, плоти — ему всё равно. Но он не пирует ради роскоши — он пожирает ради выживания клана. Свободен только тот, кто способен удержать своё и защитить его. Кто не может постоять за себя — становится добычей. В этом нет несправедливости, лишь закон природы.\n\
	Медведь учит не ждать подачек ни от ярла, ни от южного короля, ни от южных богов. Он требует, чтобы гроннец кормил себя сам, брал необходимое для клана и не позволял чужакам решать его клана. Свобода — это право сильного жить по своей воле и не служить тому, кого не способен сломить."
	associated_faith = /datum/faith/inhumen/gronn
	crafting_recipes = list()
	worshippers = "Наемники, защитники клана, налетчики."
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison									= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/appraise										= CLERIC_ORI,
					/obj/effect/proc_holder/spell/self/twilight_shacklebreaker							= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/twilight_weightofchains						= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/twilight_transact								= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/twilight_equalize								= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 									= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_heal									= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/twilight_churnwealthy							= CLERIC_T2,
					/obj/effect/proc_holder/spell/self/twilight_amongus									= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/projectile/twilight_crownfortheking			= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/twilight_commieflag							= CLERIC_T3,
					/obj/effect/proc_holder/spell/self/wildshape_twilight_wingsoffreedom				= CLERIC_T4,
	)
	confess_lines = list(
		"Я БЕРУ ЛИШЬ ТО, ЧТО НЕОБХОДИМО!",
		"МЕДВЕДЬ ОБЕРЕГАЕТ МОЙ КЛАН!",
		"Я САМ СЕБЕ ХОЗЯИН, КАК УЧИЛ НАС МЕДВЕДЬ!",
	)

/datum/patron/inhumen/baotha/irbis
	name = "The Relishing Leopard"
	translated_name = "Ирбис, Смакующая"
	rusgodnames = list(
		"Ирбис", "Ирбис", "Ирбис", "Ирбис", "Ирбис", "Ирбис",
		"Смакующая", "Смакующей", "Смакующей", "Смакующую", 
		"Смакующей", "Смакующей"
	)

	domain = "Удовольствие, наслаждение, удовлетворение желаний."
	desc = "Ирбис, постоянно плачущая и дрожащая, с пеной у рта. Она всегда находит радость в избытке.\n\
	Ирбис утоляет жажду руками твоего любовника. Пей, ешь, наслаждайся пьянящей пылью, заработанную кровью и потом. Найди радость в желаниях. Накорми внутреннего зверя, насыщай ирбиса — и наконец по-настоящему расслабься.\n\
	Но помни её предупреждения: никогда не ищи вечной нирванны. Ирбис наносит удар, когда ты разжирел и ослаб. Желание не должно быть размытым и эфемерным — нельзя хотеть всего и сразу — иначе потеряешь бдительность."
	worshippers = "Торжествующие победители и богатые ярлы."
	associated_faith = /datum/faith/inhumen/gronn
	crafting_recipes = list()
	confess_lines = list(
		"Я ЗАСЛУЖУ БЛАГОСЛОВЕНИЯ ИРБИС!",
		"ИРБИС ЖЕЛАЕТ НАМ СЧАСТЬЯ!",
		"ТЫ ТОЖЕ ДОБИВАЕШЬСЯ ЗАБОТЫ ИРБИС?!",
	)

/datum/patron/divine/dendor/volf
	name = "The Volfskinned Man"
	translated_name = "Ходящий в Волчьей Шкуре"
	rusgodnames = list(
		"Ходящий", "Ходящего", "Ходящему", "Ходящего", "Ходящим", "Ходящем"
	)

	domain = "След, добыча, обмен жизнью, мера взятого. Граница между зверем и человеком."
	desc = "Человек с волчьей головой. Он поднял копьё на волчат, которых Волчица пыталась укрыть от судьбы. Теперь он носит их шкуры и кости вместо своих, чтобы каждый помнил о цене вмешательства.\n\
	Живи по ритму леса и тундры. Убивай чисто, ешь без остатка, возвращай земле хоть каплю крови. Уважай природу — и заросли дадут тебе пройти.\n\
	Но если возьмёшь больше, чем можешь унести на спине, или убьёшь ради забавы — ты станешь таким же зверем, которого нужно освежевать."
	worshippers = "Охотники, собиратели, друиды."
	associated_faith = /datum/faith/inhumen/gronn
	confess_lines = list(
		"ОН УКРЫВАЕТ МЕНЯ ВОЛЧЬИМИ ШКУРАМИ!",
		"ЕГО ВОЛЧЬИ ГЛАЗА СМОТРЯТ В МОЮ ДУШУ!",
		"Я ОБЕРЕГАЮ ПРИРОДУ, КАК ОН ЗАВЕЩАЛ!",
	)

/datum/patron/divine/abyssor/kraken
	name = "The Spiraling Kraken"
	translated_name = "Кракен, Глубинный"
	rusgodnames = list(
		"Кракен", "Кракена", "Кракену", "Кракена", "Кракеном", "Кракене",
		"Глубинный", "Глубинного", "Глубинному", "Глубинный", 
		"Глубинным", "Глубинном"
	)

	domain = "Море, шторм, изменчивость."
	desc = "Щупальца подо льдом, ворочающийся в дрёме. Однажды он проснётся и пожрёт сушу.\n\
	Огромное спиральное тело. Он — и волны, и чёрные водовороты, и штормы.\n\
	Будь текучим, как вода. Не сопротивляйся буре — веди её. Умей ждать, когда течение само принесёт добычу. Прими как данное, что жизнь не любит постоянства — и он может пощадить тебя в самый безнадёжный момент.\n\
	Но не пытайся укротить волну, построить нерушимую гавань или привязать судьбу канатом. Или Кракен унесёт тебя в бесконечный дрейф, где нет ни берега, ни дна, ни конца. "
	worshippers = "Мореплаватели, пираты, рыболовы, торговцы."
	associated_faith = /datum/faith/inhumen/gronn
	confess_lines = list(
		"КРАКЕН — МОЯ СУДЬБА!",
		"ЯРОСТЬ ОКЕАНА ЕСТЬ СИЛА КРАКЕНА!",
		"ДА ПОГЛОТИТ ТЕБЯ КРАКЕН!",
	)

//SPELL VERSIONS

/obj/effect/proc_holder/spell/self/graggar_bloodrage/gronn
	desc = "Tap into the Moose's wellspring of strength and knowledge, granting unbound power at the cost of temporary insanity and physical exhaustion."
	invocations = list("GREAT MOOSE, GRANT ME STRENGTH!!", 
						"STRENGTH OF THE NORTH, ANSWER MY CALL!!", 
						"MY BLOOD IS ICE COLD, YOURS WILL RUN HOT!!") 

/obj/effect/proc_holder/spell/self/graggar_chainbreak/gronn
	invocations = list("GREAT MOOSE, BREAK MY CHAINS!", "GREAT MOOSE, SET ME FREE!", "YOU CANNOT HOLD BACK THE MOOSE!")

/obj/effect/proc_holder/spell/self/graggar_call_to_slaughter/gronn
	invocations = list("THE MOOSE WILL CONSUME YOU!", "FACE THE TRIAL OF THE MOOSE!")

/obj/effect/proc_holder/spell/invoked/projectile/graggar_blood_net/gronn
	invocations = list("FACE THE SERVANT OF THE MOOSE!!")

/obj/effect/proc_holder/spell/invoked/revel_in_slaughter/gronn
	invocations = list("PIN THEM TO YOUR HORNS!", "O GREAT MOOSE, MAKE THEM BLEED!")



