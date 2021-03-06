require "test_helper"

class TestJobs < GridIntegrationTest
  def host_with_name(name)
    @grid.hosts.detect { |h| h.matches?(name: name) }
  end

  def test_all_jobs_are_returned
    jobs = @grid.jobs
    assert_equal 6, jobs.size

    @grid.hosts.each do |host|
      jobs = host.jobs
      assert_match /^flynn-etcd/, jobs[0].id
      assert_match /^flynn-discoverd/, jobs[1].id
    end
  end

  def test_schedule_job_without_filter
    jobs = @grid.jobs
    assert_equal 6, jobs.size

    @grid.schedule "app"
    jobs = @grid.jobs
    assert_equal 7, jobs.size

    first_host = @grid.hosts.first
    assert_match /^app/, first_host.jobs[2].id
  end

  def test_schedule_job_with_filter
    jobs = @grid.jobs
    assert_equal 6, jobs.size

    @grid.schedule "app", on: { name: "n2" }
    jobs = @grid.jobs
    assert_equal 7, jobs.size

    matching_host = host_with_name("n2")
    jobs = matching_host.jobs
    assert_equal 3, jobs.size
    assert_match /^app/, jobs[2].id
  end

  def test_schedule_job_with_env
    env = { "FOO" => "BAR", "BAZ" => "QUX" }
    @grid.schedule "app", on: { name: "n1" }, env: env

    host = host_with_name("n1")
    job  = host.jobs[2]
    assert_match /^app/, job.id
    assert_equal "BAR", job.env["FOO"]
    assert_equal "QUX", job.env["BAZ"]
  end

  def test_schedule_job_with_volumes
    volumes = {
      "/tmp/vol1" => nil,
      "/tmp/vol2" => "/host/vol2"
    }

    @grid.schedule "app", on: { name: "n1" }, volumes: volumes

    host = host_with_name("n1")
    job  = host.jobs[2]
    assert_match /^app/, job.id
    assert_equal volumes, job.volumes
  end

  def test_schedule_job_with_ports
    ports = {
      "tcp" => [4444, 5555],
      "udp" => [6666, 7777]
    }

    @grid.schedule "app", on: { name: "n1" }, ports: ports

    host = host_with_name("n1")
    job  = host.jobs[2]
    assert_match /^app/, job.id
    assert_equal ports, job.ports
  end
end
