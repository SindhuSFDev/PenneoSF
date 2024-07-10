/**
 * Created on 07-09-2020
 **/
public class DataCategoryPicklist extends VisualEditor.DynamicPickList{
	public override VisualEditor.DataRow getDefaultValue(){
		return null;
	}

	public override VisualEditor.DynamicPickListRows getValues(){
		//To get all categories values and add them as picklist
		VisualEditor.DynamicPickListRows picklistValues = new VisualEditor.DynamicPickListRows();
		List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult = KnowArticleController.getDescribeDataCategoryGroupStructureResults();
		VisualEditor.DataRow picklistAllRow = new VisualEditor.DataRow('All', 'All');
		picklistValues.addRow(picklistAllRow);
		for (DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
			VisualEditor.DataRow picklistRow = new VisualEditor.DataRow(singleResult.getLabel(), singleResult.getName());
			picklistValues.addRow(picklistRow);
		}
		return picklistValues;
	}
}