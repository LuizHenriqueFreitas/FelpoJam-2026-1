extends Area3D
class_name Carimbo

enum Raridade { COMUM, INCOMUM, RARO }
enum TipoUnidade { GUERREIRO, ARQUEIRO, CANHAO }

@export var nome: String = "Carimbo"
@export var raridade: Raridade = Raridade.COMUM
@export var tipo_unidade: TipoUnidade = TipoUnidade.GUERREIRO
@export var gravura: Texture2D

@export var pontos_totais: int = 5
@export var ataque: int = 0
@export var vida: int = 0
@export var velocidade: int = 0

const MAX_POR_ATRIBUTO: int = 10

const DISPLAY_SCENE = preload("res://menus/displaycarimbo.tscn")

const PONTOS_POR_RARIDADE = {
	Raridade.COMUM:   5,
	Raridade.INCOMUM: 8,
	Raridade.RARO:    12,
}

# Mínimo de pontos livres por atributo que o carimbo pode ter
# Comum: 4 livres (pode ter no max 1 pré-gasto)
# Incomum: 3 livres (pode ter no max 2 pré-gastos)
# Raro: 2 livres (pode ter no max 3 pré-gastos)
const PONTOS_LIVRES_MIN = {
	Raridade.COMUM:   4,
	Raridade.INCOMUM: 3,
	Raridade.RARO:    2,
}

# Chance de vir com pontos pré-distribuídos
const CHANCE_PRE_DISTRIBUIDO = {
	Raridade.COMUM:   0.2,   
	Raridade.INCOMUM: 0.5,   
	Raridade.RARO:    0.8,   
}

const NOMES_RARIDADE = {
	Raridade.COMUM:   "Comum",
	Raridade.INCOMUM: "Incomum",
	Raridade.RARO:    "Raro",
}

const CORES_RARIDADE = {
	Raridade.COMUM:   Color(0.75, 0.75, 0.75),
	Raridade.INCOMUM: Color(0.2,  0.8,  0.2),
	Raridade.RARO:    Color(0.2,  0.4,  1.0),
}

const NOMES_UNIDADE = {
	TipoUnidade.GUERREIRO: "Guerreiro",
	TipoUnidade.ARQUEIRO:  "Arqueiro",
	TipoUnidade.CANHAO:    "Canhão",
}

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_ao_coletar(body)
		
func _ao_coletar(player: Node3D) -> void:
	var display = DISPLAY_SCENE.instantiate()
	get_tree().root.add_child(display)
	display.carregar_carimbo(self)
	


func inicializar(r: Raridade):
	raridade     = r
	pontos_totais = PONTOS_POR_RARIDADE[r]
	ataque       = 0
	vida         = 0
	velocidade   = 0
	tipo_unidade = TipoUnidade.values()[randi() % TipoUnidade.size()]

	# Tenta pré-distribuir pontos com base na raridade
	if randf() < CHANCE_PRE_DISTRIBUIDO[r]:
		_pre_distribuir()


func _pre_distribuir():
	var livres_min  = PONTOS_LIVRES_MIN[raridade]
	# Máximo de pontos que podem ser pré-gastos (garantindo livres_min livres)
	var max_pre     = pontos_totais - livres_min
	if max_pre <= 0:
		return

	# Sorteia quantos pontos serão pré-gastos (entre 1 e max_pre)
	var pre_gastos  = randi() % max_pre + 1
	var attrs       = ["ataque", "vida", "velocidade"]

	# Distribui aleatoriamente entre os atributos
	for _i in range(pre_gastos):
		attrs.shuffle()
		for attr in attrs:
			var atual = get(attr)
			if atual < MAX_POR_ATRIBUTO:
				set(attr, atual + 1)
				break


func pontos_gastos() -> int:
	return ataque + vida + velocidade


func pontos_restantes() -> int:
	return pontos_totais - pontos_gastos()


func pode_adicionar(atributo: String) -> bool:
	if pontos_restantes() <= 0:
		return false
	match atributo:
		"ataque":     return ataque < MAX_POR_ATRIBUTO
		"vida":       return vida < MAX_POR_ATRIBUTO
		"velocidade": return velocidade < MAX_POR_ATRIBUTO
	return false


func pode_remover(atributo: String) -> bool:
	match atributo:
		"ataque":     return ataque > 0
		"vida":       return vida > 0
		"velocidade": return velocidade > 0
	return false
	
