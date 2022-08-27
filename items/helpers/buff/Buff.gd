extends RefCounted
class_name Buff

signal buff_expired(buff)

var buff_id # only used for persistent buffs...probably
var buff_name
var provider_id
var __provider
var __recipient
var timer:int = 0
var persistent:bool = false
var add_effects = null # stat -> amount to be used if no owner callback/provider callback exists
var mult_effects = null # stat -> amount to be used if no owner callback/provider callback exists
var __add_callbacks = {}
var __mult_callbacks = {}

static func build_buff(buff_name:String, provider_id, timer:int, persistent:bool=false):
	var buff = Buff.new()
	buff.buff_name = buff_name
	buff.provider_id = provider_id
	buff.timer = timer
	buff.persistent = persistent
	return buff

static func copy_for_recipient(other:Buff, recipient_id):
	var result = Buff.new()
	result.buff_id = other.buff_id
	result.buff_name = other.buff_name
	result.provider_id = other.provider_id
	result.timer = other.timer
	result.persistent = other.persistent
	result.add_effects = other.add_effects
	result.mult_effects = other.mult_effects
	return result

func add_effect(stat_name, default_amt=0):
	if add_effects == null:
		add_effects = {}
	add_effects[stat_name] = default_amt

func mult_effect(stat_name, default_amt=1.0):
	if mult_effects == null:
		mult_effects = {}
	mult_effects[stat_name] = default_amt

func setup(recipient_id):
	__provider = IdManager.get_item_by_id(provider_id)
	__recipient = IdManager.get_item_by_id(recipient_id)
	if add_effects != null:
		for stat_name in add_effects:
			var callback_name = 'buff_%s_add_%s' % [buff_name, stat_name]
			if __recipient.has_method(callback_name):
				__add_callbacks[stat_name] = Callable(__recipient, callback_name)
			elif __provider.has_method(callback_name):
				__add_callbacks[stat_name] = Callable(__provider, callback_name)
			else:
				__add_callbacks[stat_name] = func(provider): return add_effects.get(stat_name, 0)
	if mult_effects != null:
		for stat_name in mult_effects:
			var callback_name = 'buff_%s_multiply_%s' % [buff_name, stat_name]
			if __recipient.has_method(callback_name):
				__mult_callbacks[stat_name] = Callable(__recipient, callback_name)
			elif __provider.has_method(callback_name):
				__mult_callbacks[stat_name] = Callable(__provider, callback_name)
			else:
				__mult_callbacks[stat_name] = func(provider): return mult_effects.get(stat_name, 0)

func get_add_buff(stat_name) -> float:
	var callback = __add_callbacks.get(stat_name)
	if callback == null:
		return 0.0
	else:
		return callback.call(__provider)

func get_multiply_buff(stat_name) -> float:
	var callback = __mult_callbacks.get(stat_name, null)
	if callback == null:
		return 1.0
	else:
		return callback.call(__provider)

