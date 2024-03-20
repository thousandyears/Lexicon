export interface LemmaDetails {
  id: string;
}

export interface I {
  _: LemmaDetails;
}

export class L implements I {
  _: LemmaDetails;
  constructor(parent: string | undefined, name: string) {
    this._ = {
     id: parent ? `${parent}.${name}` : name,
    };
  }
  toString(): string {
    return this._.id;
  }
}

export class L_root extends L implements I_root {
  get plant() { return new L_root_plant(this._.id, `plant`) }
  get resource() { return new L_root_resource(this._.id, `resource`) }
  get tree() { return new L_root_tree(this._.id, `tree`) }
  get twig() { return this.tree.branch; }
}
export interface I_root extends I {
  plant: I_root_plant;
  resource: I_root_resource;
  tree: I_root_tree;
  twig: I_root_tree_branch;
}

export class L_root_plant extends L implements I_root_plant {
  get leaf() { return new L_root_plant_leaf(this._.id, `leaf`) }
}
export interface I_root_plant extends I {
  leaf: I_root_plant_leaf;
}

export class L_root_plant_leaf extends L implements I_root_plant_leaf {
}
export interface I_root_plant_leaf extends I {
}

export class L_root_resource extends L implements I_root_resource {
  get price() { return new L_root_resource_price(this._.id, `price`) }
}
export interface I_root_resource extends I {
  price: I_root_resource_price;
}

export class L_root_resource_price extends L implements I_root_resource_price {
}
export interface I_root_resource_price extends I {
}

export class L_root_tree extends L implements I_root_tree {
  get branch() { return new L_root_tree_branch(this._.id, `branch`) }
  get leaf() { return new L_root_plant_leaf(this._.id, `leaf`) }
  get price() { return new L_root_resource_price(this._.id, `price`) }
  get twig() { return this.branch; }
}
export interface I_root_tree extends I_root_plant, I_root_resource {
  branch: I_root_tree_branch;
  twig: I_root_tree_branch;
}

export class L_root_tree_branch extends L implements I_root_tree_branch {
  get branch() { return new L_root_tree_branch(this._.id, `branch`) }
  get leaf() { return new L_root_plant_leaf(this._.id, `leaf`) }
  get price() { return new L_root_resource_price(this._.id, `price`) }
  get twig() { return this.branch; }
}
export interface I_root_tree_branch extends I_root_tree {
}


export const root = new L_root(undefined, "root");