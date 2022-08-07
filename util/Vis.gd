extends Object
class_name Vis

const KEY_TYPE:='vt'
const KEY_SIZE:='vs'
const KEY_AMOUNT:='va'
const KEY_MAX_AMOUNT:='vx'

const TYPE_IMPURE:=0

const VIS_TYPE_NAMES:={
	TYPE_IMPURE: 'impure'
}

static func vis_type_name(vis_type):
	return VIS_TYPE_NAMES.get(vis_type, 'unknown')

# For each supplier in the array, if the supplier has more vis than the consumer returns from 'get_vis()',
# then try to transfer enough to bring the vis_consumer up to the amount available in the supplier
# The supplier will have get_vis(), drain_vis(vis_amount) and get_vis_type() called
# The consumer will have get_vis() and receive_vis(vis_type, vis_amount) called
static func equalize_vis_with_all_suppliers(vis_suppliers:Array, vis_consumer:GameItem):
	if vis_suppliers == null or !vis_suppliers.size():
		return
	var consumer_vis = vis_consumer.get_vis()
	for vis_supplier in vis_suppliers:
		var supplier_vis = vis_supplier.get_vis()
		if supplier_vis > consumer_vis:
			var requested = supplier_vis - consumer_vis
			var supplied = vis_supplier.drain_vis(requested)
			vis_consumer.receive_vis(vis_supplier.get_vis_type(), supplied)
			consumer_vis = vis_consumer.get_vis()

