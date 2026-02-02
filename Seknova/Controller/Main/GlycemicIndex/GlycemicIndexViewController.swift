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
        print("👋 頁面即將消失，停止 Timer")
        timer?.invalidate()
        timer = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("👀 頁面即將顯示")
        
        // 每次回到頁面時重置圖表大小
        resetChartZoom()
        
        // 如果 timer 不存在，重新啟動（防止被意外停止）
        if timer == nil || timer?.isValid == false {
            print("⚠️ Timer 不存在或已失效，重新啟動")
            startRealTimeUpdates()
        }
    }
    
    // MARK: - UI Settings
    func setUI() {
        navigationItem.hidesBackButton = true
        title = "即時血糖"
        
        // 添加右側圓環進度條按鈕
        setupCircularProgressButton()
        
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
    
    // MARK: - Circular Progress Button
    private func setupCircularProgressButton() {
        let circularButton = createCircularProgressView()
        let barButtonItem = UIBarButtonItem(customView: circularButton)
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func createCircularProgressView() -> UIView {
        let aDegree = Double.pi / 180
        let lineWidth: Double = 8  // 進度條線條寬度
        let radius: Double = 13  // 圓環半徑
        let startDegree: Double = 270
        let outerBorderWidth: Double = 1  // 外圍黑色描邊寬度
        
        // 創建外圍黑色描邊圓環
        let outerRadius = radius + lineWidth/2 + outerBorderWidth/2
        let outerCirclePath = UIBezierPath(arcCenter: CGPoint(x: lineWidth + radius + outerBorderWidth,
                                                               y: lineWidth + radius + outerBorderWidth),
                                          radius: outerRadius,
                                          startAngle: 0,
                                          endAngle: 2 * Double.pi,
                                          clockwise: true)
        let outerBorderLayer = CAShapeLayer()
        outerBorderLayer.path = outerCirclePath.cgPath
        outerBorderLayer.strokeColor = UIColor.black.cgColor
        outerBorderLayer.lineWidth = outerBorderWidth
        outerBorderLayer.fillColor = UIColor.clear.cgColor
        
        // 創建內側黑色描邊圓環（空心部分的邊緣）
        let innerRadius = radius - lineWidth/1.5
        let innerCirclePath = UIBezierPath(arcCenter: CGPoint(x: lineWidth + radius + outerBorderWidth,
                                                               y: lineWidth + radius + outerBorderWidth),
                                          radius: innerRadius,
                                          startAngle: 0,
                                          endAngle: 2 * Double.pi,
                                          clockwise: true)
        let innerBorderLayer = CAShapeLayer()
        innerBorderLayer.path = innerCirclePath.cgPath
        innerBorderLayer.strokeColor = UIColor.black.cgColor
        innerBorderLayer.lineWidth = outerBorderWidth
        innerBorderLayer.fillColor = UIColor.clear.cgColor
        
        // 創建背景圓環（淺灰色）
        let circlePath = UIBezierPath(ovalIn: CGRect(x: lineWidth + outerBorderWidth,
                                                      y: lineWidth + outerBorderWidth,
                                                      width: radius*2,
                                                      height: radius*2))
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.strokeColor = UIColor(white: 0.9, alpha: 1).cgColor
        circleLayer.lineWidth = lineWidth
        circleLayer.fillColor = UIColor.clear.cgColor
        
        // 創建進度圓環 (假設60%進度) - 使用紅色/橘色
        let percentage: CGFloat = 60
        let endDegree = startDegree + 360 * Double(percentage) / 100
        let percentagePath = UIBezierPath(arcCenter: CGPoint(x: lineWidth + radius + outerBorderWidth,
                                                              y: lineWidth + radius + outerBorderWidth),
                                        radius: radius,
                                        startAngle: aDegree * startDegree,
                                        endAngle: aDegree * endDegree,
                                        clockwise: true)
        let percentageLayer = CAShapeLayer()
        percentageLayer.path = percentagePath.cgPath
        percentageLayer.strokeColor = UIColor.green.cgColor  // 改回綠色
        percentageLayer.lineWidth = lineWidth
        percentageLayer.fillColor = UIColor.clear.cgColor
        
        // 在進度條起點添加黑色標記線（頂部中心點）
        let startMarkerPath = UIBezierPath()
        let startAngleRad = aDegree * startDegree
        let startX = lineWidth + radius + outerBorderWidth + radius * cos(startAngleRad)
        let startY = lineWidth + radius + outerBorderWidth + radius * sin(startAngleRad)
        let startOuterX = lineWidth + radius + outerBorderWidth + (radius + lineWidth/2) * cos(startAngleRad)
        let startOuterY = lineWidth + radius + outerBorderWidth + (radius + lineWidth/2) * sin(startAngleRad)
        startMarkerPath.move(to: CGPoint(x: startX, y: startY))
        startMarkerPath.addLine(to: CGPoint(x: startOuterX, y: startOuterY))
        
        let startMarkerLayer = CAShapeLayer()
        startMarkerLayer.path = startMarkerPath.cgPath
        startMarkerLayer.strokeColor = UIColor.black.cgColor
        startMarkerLayer.lineWidth = 2
        
        // 在進度條終點添加黑色標記線
        let endMarkerPath = UIBezierPath()
        let endAngleRad = aDegree * endDegree
        let endX = lineWidth + radius + outerBorderWidth + radius * cos(endAngleRad)
        let endY = lineWidth + radius + outerBorderWidth + radius * sin(endAngleRad)
        let endOuterX = lineWidth + radius + outerBorderWidth + (radius + lineWidth/2) * cos(endAngleRad)
        let endOuterY = lineWidth + radius + outerBorderWidth + (radius + lineWidth/2) * sin(endAngleRad)
        endMarkerPath.move(to: CGPoint(x: endX, y: endY))
        endMarkerPath.addLine(to: CGPoint(x: endOuterX, y: endOuterY))
        
        let endMarkerLayer = CAShapeLayer()
        endMarkerLayer.path = endMarkerPath.cgPath
        endMarkerLayer.strokeColor = UIColor.black.cgColor
        endMarkerLayer.lineWidth = 2
        
        // 創建容器視圖 (需要增加尺寸以容納外圍描邊)
        let viewWidth = 2*(radius + lineWidth + outerBorderWidth)
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewWidth))
        containerView.layer.addSublayer(outerBorderLayer)  // 先添加外圍描邊
        containerView.layer.addSublayer(innerBorderLayer)  // 添加內側描邊
        containerView.layer.addSublayer(circleLayer)
        containerView.layer.addSublayer(percentageLayer)
        containerView.layer.addSublayer(startMarkerLayer)  // 添加起點標記線
        containerView.layer.addSublayer(endMarkerLayer)    // 添加終點標記線
        
        // 添加點擊手勢
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(circularProgressTapped))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
        
        return containerView
    }
    
    @objc private func circularProgressTapped() {
        showSensorStatusPopup()
    }
    
    private func showSensorStatusPopup() {
        // 如果彈窗已經顯示，則關閉它
        if let existingPopup = view.viewWithTag(999) {
            hideSensorStatusPopup()
            return
        }
        
        // 創建彈出視窗，類似選單的顯示方式
        let popupWidth: CGFloat = 200
        let popupHeight: CGFloat = 280
        
        // 計算右上角位置
        let popupX = view.bounds.width - popupWidth - 10
        let popupY: CGFloat = 10 // 貼近導航欄底部
        
        let popupView = UIView(frame: CGRect(
            x: popupX,
            y: popupY,
            width: popupWidth,
            height: popupHeight
        ))
        popupView.backgroundColor = .white
        popupView.tag = 999 // 用於後續移除
        popupView.layer.cornerRadius = 12
        popupView.layer.shadowColor = UIColor.black.cgColor
        popupView.layer.shadowOpacity = 0.3
        popupView.layer.shadowOffset = CGSize(width: 0, height: 2)
        popupView.layer.shadowRadius = 8
        
        // 創建大的圓環進度條
        let bigCircularView = createBigCircularProgressView()
        bigCircularView.frame = CGRect(x: (popupWidth - 120) / 2, y: 20, width: 120, height: 120)
        popupView.addSubview(bigCircularView)
        
        // 添加 "10 Day" 標籤
        let dayLabel = UILabel()
        dayLabel.text = "10 Day"
        dayLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        dayLabel.textAlignment = .center
        dayLabel.frame = CGRect(x: 0, y: 150, width: popupWidth, height: 25)
        popupView.addSubview(dayLabel)
        
        // 添加 "Calibrated Now" 標籤
        let calibratedLabel = UILabel()
        calibratedLabel.text = "Calibrated Now"
        calibratedLabel.font = UIFont.systemFont(ofSize: 16)
        calibratedLabel.textAlignment = .center
        calibratedLabel.frame = CGRect(x: 0, y: 180, width: popupWidth, height: 20)
        popupView.addSubview(calibratedLabel)
        
        // 添加日曆圖標
        let calendarIcon = UIImageView()
        if let image = UIImage(systemName: "calendar") {
            calendarIcon.image = image
            calendarIcon.tintColor = .orange
        }
        calendarIcon.frame = CGRect(x: (popupWidth - 30) / 2, y: 210, width: 30, height: 30)
        popupView.addSubview(calendarIcon)
        
        // 添加關閉手勢
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideSensorStatusPopup))
        view.addGestureRecognizer(tapGesture)
        
        view.addSubview(popupView)
        
        // 添加動畫效果
        popupView.alpha = 0
        popupView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            popupView.alpha = 1
            popupView.transform = .identity
        }
    }
    
    @objc private func hideSensorStatusPopup() {
        guard let popupView = view.viewWithTag(999) else { return }
        
        // 移除手勢識別器
        view.gestureRecognizers?.removeAll { $0.isKind(of: UITapGestureRecognizer.self) }
        
        UIView.animate(withDuration: 0.2, animations: {
            popupView.alpha = 0
            popupView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            popupView.removeFromSuperview()
        }
    }
    
    private func createBigCircularProgressView() -> UIView {
        let aDegree = Double.pi / 180
        let lineWidth: Double = 10
        let radius: Double = 50
        let startDegree: Double = 270
        
        // 創建背景圓環
        let circlePath = UIBezierPath(ovalIn: CGRect(x: lineWidth, y: lineWidth, width: radius*2, height: radius*2))
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.strokeColor = UIColor.lightGray.cgColor
        circleLayer.lineWidth = lineWidth
        circleLayer.fillColor = UIColor.clear.cgColor
        
        // 創建進度圓環
        let percentage: CGFloat = 60
        let endDegree = startDegree + 360 * Double(percentage) / 100
        let percentagePath = UIBezierPath(arcCenter: CGPoint(x: lineWidth + radius, y: lineWidth + radius),
                                        radius: radius,
                                        startAngle: aDegree * startDegree,
                                        endAngle: aDegree * endDegree,
                                        clockwise: true)
        let percentageLayer = CAShapeLayer()
        percentageLayer.path = percentagePath.cgPath
        percentageLayer.strokeColor = UIColor.green.cgColor
        percentageLayer.lineWidth = lineWidth
        percentageLayer.fillColor = UIColor.clear.cgColor
        
        // 創建容器視圖
        let viewWidth = 2*(radius+lineWidth)
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewWidth))
        containerView.layer.addSublayer(circleLayer)
        containerView.layer.addSublayer(percentageLayer)
        
        // 添加中間的問號圖標
        let questionMark = UILabel(frame: containerView.bounds)
        questionMark.textAlignment = .center
        questionMark.text = "?"
        questionMark.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        questionMark.textColor = .black
        containerView.addSubview(questionMark)
        
        return containerView
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
