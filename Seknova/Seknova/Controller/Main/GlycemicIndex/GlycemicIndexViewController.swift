//
//  GlycemicIndexViewController.swift
//  Seknova
//
import UIKit
import DGCharts

class GlycemicIndexViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var myView: LineChartView!
    @IBOutlet weak var Glylb: UILabel!
    
    // MARK: - Variables
    private var timeArray: [String] = []
    private var dataEntries: [ChartDataEntry] = []
    private var timer: Timer?
    private let maxDataPoints = 6 // 對應 5 個方格間距
    private var startTime: Date!
    private var currentBloodGlucose: Double = 0
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupChart()
        startRealTimeUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 每次回到頁面時重置圖表大小
        resetChartZoom()
    }
    
    // MARK: - UI Settings
    func setUI() {
        navigationItem.hidesBackButton = true
        title = "即時血糖"
        
        // 設置起始時間
        startTime = Date()
        setupTimePoints()
        
        // 初始化血糖數值
        currentBloodGlucose = Double.random(in: 70...250)
        updateCurrentBloodGlucoseDisplay()
    }
    
    private func setupTimePoints() {
        timeArray.removeAll()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        // 從當前時間開始，每 12 分鐘一個標籤，共 6 個標籤形成 5 個方格寬
        for i in 0..<maxDataPoints {
            let timePoint = startTime.addingTimeInterval(TimeInterval(i * 12 * 60))
            timeArray.append(formatter.string(from: timePoint))
        }
    }
    
    private func updateCurrentBloodGlucoseDisplay() {
        Glylb?.text = String(format: "%.0f", currentBloodGlucose)
    }
    
    // MARK: - Chart Setup
    private func setupChart() {
        guard let chartView = myView else { return }
        
        // 基礎外觀
        chartView.backgroundColor = .white
        chartView.chartDescription.enabled = false
        chartView.legend.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        
        // --- X 軸：長度 5 格 (0 到 5) ---
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = true
        xAxis.gridColor = .lightGray.withAlphaComponent(0.6)
        xAxis.axisMinimum = 0
        xAxis.axisMaximum = 5
        xAxis.labelCount = 6 // 顯示 6 個標籤，剛好形成 5 格長
        xAxis.granularity = 1
        xAxis.valueFormatter = IndexAxisValueFormatter(values: timeArray)
        
        // --- Y 軸：高度 4 格 (0 到 400) ---
        let leftAxis = chartView.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 400
        leftAxis.labelCount = 5 // 顯示 0, 100, 200, 300, 400，形成 4 格高
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = .lightGray.withAlphaComponent(0.6)
        leftAxis.decimals = 0 // 不顯示小數點
        leftAxis.granularity = 100 // Y軸標籤間隔為100，確保整數顯示
        
        // 創建橘色區域使用多條 LimitLine，顏色為 #FFCE83，透明度 50%
        leftAxis.removeAllLimitLines()
        
        // 創建密集的水平線來形成橘色區域 (從 70 到 200)
        for y in stride(from: 70, through: 200, by: 0.5) {
            let line = ChartLimitLine(limit: Double(y), label: "")
            line.lineColor = UIColor(red: 245/255.0, green: 193/255.0, blue: 134/255.0, alpha: 0.5)
            line.lineWidth = 1
            leftAxis.addLimitLine(line)
        }
        
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        chartView.rightAxis.enabled = false
        
        updateChartData()
    }
    
    private func updateChartData() {
        guard let chartView = myView else { return }
        
        // 只創建血糖值折線數據集，橘色背景由 LimitLine 處理
        let bloodGlucoseDataSet = LineChartDataSet(entries: dataEntries, label: "血糖值")
        
        // 設置紅色折線樣式
        bloodGlucoseDataSet.colors = [.systemRed]
        bloodGlucoseDataSet.lineWidth = 2.5
        bloodGlucoseDataSet.circleRadius = 4
        bloodGlucoseDataSet.circleColors = [.systemRed]
        bloodGlucoseDataSet.circleHoleColor = .white
        bloodGlucoseDataSet.drawCircleHoleEnabled = true
        bloodGlucoseDataSet.drawValuesEnabled = false
        bloodGlucoseDataSet.mode = .linear
        
        let data = LineChartData(dataSet: bloodGlucoseDataSet)
        chartView.data = data
        
        // 強制刷新圖表
        chartView.notifyDataSetChanged()
    }
    
    private func resetChartZoom() {
        myView.setVisibleXRangeMinimum(1)
        myView.setVisibleXRangeMaximum(5)
        myView.leftAxis.axisMinimum = 0
        myView.leftAxis.axisMaximum = 400
        myView.notifyDataSetChanged()
    }
}

// MARK: - Real Time Updates
extension GlycemicIndexViewController {
    private func startRealTimeUpdates() {
        // 每 3 秒更新一次點，模擬即時數據流
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.addNewDataPoint()
        }
    }
    
    private func addNewDataPoint() {
        // 隨機生成新數值
        let newBloodGlucose = Double.random(in: 60...380)
        currentBloodGlucose = newBloodGlucose
        
        print("添加新數據點：\(String(format: "%.0f", newBloodGlucose))")
        
        if dataEntries.count < maxDataPoints {
            // 資料尚未填滿 X 軸前，由左至右增加點
            let newEntry = ChartDataEntry(x: Double(dataEntries.count), y: newBloodGlucose)
            dataEntries.append(newEntry)
            print("新增數據點，總數：\(dataEntries.count)")
        } else {
            // 資料已滿 6 個點，將數據向左平移，新的點加在最右邊
            for i in 0..<dataEntries.count - 1 {
                dataEntries[i].y = dataEntries[i+1].y
            }
            dataEntries[maxDataPoints - 1].y = newBloodGlucose
            print("更新數據點，總數保持：\(dataEntries.count)")
        }
        
        // 回到主執行緒更新 UI
        DispatchQueue.main.async { [weak self] in
            self?.updateChartData()
            self?.updateCurrentBloodGlucoseDisplay()
        }
    }
}
