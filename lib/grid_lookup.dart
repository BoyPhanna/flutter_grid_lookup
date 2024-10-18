library grid_lookup;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

///Grid Lookup Boyimport 'package:flutter/material.dart';

class GridLookup<T> extends StatefulWidget {
  final double? tableWidth;
  final double? tableHeight;
  final double? inputWidth;
  final double? inputHeight;
  final double? buttonSize;
  final int? selectColumnIndex;
  final Function(String)? onSelectedMenu;
  final GridLookupDataSorce<T>? dataSource; // Use the generic data source

  final TextStyle? textStyle;

  const GridLookup({
    super.key,
    this.tableWidth,
    this.tableHeight,
    this.inputWidth,
    this.inputHeight,
    this.buttonSize,
    this.selectColumnIndex,
    this.onSelectedMenu,
    this.dataSource,
    this.textStyle,
  });

  @override
  State<GridLookup> createState() => _GridLookupState<T>();
}

class _GridLookupState<T> extends State<GridLookup<T>> {
  final OverlayPortalController _tooltipController = OverlayPortalController();
  TextEditingController filterController = TextEditingController();
  GridLookupDataSorce<T>? dataSource;

  @override
  void initState() {
    super.initState();
    dataSource = widget.dataSource; // Get the passed data source

    // Listen to the text field changes to filter the data
    filterController.addListener(() {
      dataSource!.filterData(filterController.text);
    });
  }

  final _link = LayerLink();

  @override
  Widget build(BuildContext context) {
    final width = widget.inputWidth ?? 400;
    final height = widget.inputHeight ?? 30;
    final buttonSize = widget.buttonSize ?? 30;
    final selectColumnIndex = widget.selectColumnIndex ?? 0;

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _tooltipController,
        overlayChildBuilder: (BuildContext context) {
          return CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomLeft,
            child: Align(
              alignment: AlignmentDirectional.topStart,

              // Combo Box Menu
              child: Container(
                width: widget.tableWidth ?? 400,
                height: widget.tableHeight ?? 400,
                color: Colors.white,
                child: SfDataGrid(
                  onCellTap: (details) {
                    onTap();
                    if (details.rowColumnIndex.rowIndex != 0) {
                      final DataGridRow tappedRow =
                          dataSource!.rows[details.rowColumnIndex.rowIndex - 1];
                      final cellValue =
                          tappedRow.getCells()[selectColumnIndex].value;
                      filterController.text = cellValue.toString();
                      widget.onSelectedMenu?.call(cellValue.toString());
                    }
                  },
                  showCheckboxColumn: true,
                  selectionMode: SelectionMode.single,
                  source: dataSource!,
                  columns: widget.dataSource!.columns.map((columnName) {
                    return GridColumnGridLookup(columnName, columnName);
                  }).toList(),
                ),
              ),
            ),
          );
        },

        // Input Text Field
        child: SizedBox(
          height: height,
          width: width,
          child: Row(
            children: [
              // Input Text Field
              SizedBox(
                height: height,
                width: width - buttonSize,
                child: TextField(
                  onChanged: (value) {
                    _tooltipController.show();
                  },
                  style:
                      widget.textStyle ?? const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: (height - 20) /
                          2, // Adjust vertical padding based on height
                      horizontal:
                          8.0, // Horizontal padding for left and right space
                    ),
                    border: OutlineInputBorder(),
                  ),
                  controller: filterController,
                ),
              ),

              // Button to toggle the drop-down
              SizedBox(
                height: buttonSize,
                width: buttonSize,
                child: Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black12),
                  ),
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(10),
                    child: Center(
                      child: Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Toggle Combo Box Menu
  void onTap() {
    _tooltipController.toggle();
  }

  @override
  void dispose() {
    filterController.dispose();
    super.dispose();
  }
}

// Helper function to create GridColumn with a dynamic name and title
GridColumn GridColumnGridLookup(String columnName, String columnTitle) {
  return GridColumn(
    columnWidthMode: ColumnWidthMode.fill,
    columnName: columnName,
    label: Container(
      padding: EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child: Text(
        columnTitle,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}

class GridLookupDataSorce<T> extends DataGridSource {
  final List<T> data;
  final List<String> columns; // The list of column names to display
  List<T> filteredData = [];

  GridLookupDataSorce({
    required this.data,
    required this.columns,
  }) {
    filteredData = data;
  }

  @override
  List<DataGridRow> get rows => filteredData.map<DataGridRow>((item) {
        return DataGridRow(
          cells: columns.map((column) {
            final dynamic value = _getFieldValue(item, column);
            return DataGridCell<dynamic>(columnName: column, value: value);
          }).toList(),
        );
      }).toList();

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataCell) {
        return Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(dataCell.value.toString()),
        );
      }).toList(),
    );
  }

  dynamic _getFieldValue(T item, String fieldName) {
    final itemAsMap = item as Map<String, dynamic>;
    return itemAsMap[fieldName];
  }

  void filterData(String filterValue) {
    if (filterValue.isEmpty) {
      filteredData = data;
    } else {
      filteredData = data.where((item) {
        return columns.any((column) {
          final value = _getFieldValue(item, column).toString().toLowerCase();
          return value.contains(filterValue.toLowerCase());
        });
      }).toList();
    }
    notifyListeners(); // Refresh the DataGrid
  }
}

abstract class GridLookupClas {
  Map<String, dynamic> toMap();
}
