import { Spell } from '../../../../models/spell';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { SPELL_DETAIl_PAGE_ROUTE } from '../../../../utils/Routes';
import { SpellsViewModel } from '../../viewmodel/SpellsViewModel';
import { Context } from '@kit.AbilityKit';


@Entry
@Component
struct spells {
  private spellsViewModel = new SpellsViewModel();

  private UIContext(): UIContext {
    return this.getUIContext();
  }

  private Context(): Context | undefined {
    return this.getUIContext().getHostContext();
  }

  @State spells: Array<Spell> = [];

  async aboutToAppear() {
    if (this.Context() != undefined) {
      await this.spellsViewModel.fetchSpells(this.Context()!);
    }
  }

  build() {
    List() {
      ForEach(this.spells, (item: Spell) => {
        ListItem() {
          Row() {
            if (item.incantation != null) {
              Text(`${item.incantation} - `).fontSize(10)
            }
            Text(item.name).fontSize(10)
          }.padding({
            bottom: 5,
            top: 5,
            left: 25,
          }
          )
        }.onClick(() => {
          this.UIContext().getRouter().pushUrl({
            url: SPELL_DETAIl_PAGE_ROUTE,
            params: { id: item.id }
          }).catch((error: Error) => {
            console.log(Error.toString());
          });
        })
      })
    }
    .width('100%')
    .alignListItem(ListItemAlign.Start)

  }
}