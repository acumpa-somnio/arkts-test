export class Spell{
  id:string =''
  name:string =''
  incantation:string =''
  effect:string =''
  canBeVerbal:boolean = true
  type:string =''
  light:string =''
  creator:string|null

  constructor(id:string, name:string, incantation:string, effect:string, canBeVerbal:boolean, type:string, light:string, creator:string|null) {
    this.id = id
    this.name = name
    this.incantation = incantation
    this.effect = effect
    this.canBeVerbal = canBeVerbal
    this.type = type
    this.light = light
    this.creator = creator
  }

  static fromJson(json:object): Spell{
    let id = Reflect.get(json, 'id') as string;
    let name = Reflect.get(json, 'name') as string;
    let incantation = Reflect.get(json, 'incantation') as string;
    let effect = Reflect.get(json, 'effect') as string;
    let canBeVerBal = Reflect.get(json, 'canBeVerbal') as boolean;
    let type = Reflect.get(json, 'type') as string;
    let light = Reflect.get(json, 'light') as string;
    let creator = Reflect.get(json, 'creator') as string|null;

    return new Spell(id,name,incantation, effect, canBeVerBal, type,light,creator);
  }

  static empty() : Spell{
  return new Spell('','','','',false,'','','',);

  }

  toString():string{
    return this.name;
  }
}